import { isError } from "$lib/utils/helpers";
import type {
  CreateF1Team,
  GetF1Team,
  ListF1Teams,
  F1Team,
  F1Teams,
  UpdateF1Team,
} from "../../../../declarations/backend/backend.did";
import { ActorFactory } from "$lib/utils/actor.factory";
import { authStore } from "$lib/stores/auth-store";
import type { OptionIdentity } from "$lib/types/identity";
import { IDL } from "@dfinity/candid";
import { createAgent } from "@dfinity/utils";
import { SnsGovernanceCanister } from "@dfinity/sns";
import { Principal } from "@dfinity/principal";
import type {
  Command,
  ExecuteGenericNervousSystemFunction,
} from "@dfinity/sns/dist/candid/sns_governance";

const AddF1Team_Idl = IDL.Record({
  name: IDL.Text,
  friendlyName: IDL.Text,
  thirdColourHex: IDL.Text,
  primaryColourHex: IDL.Text,
  secondaryColourHex: IDL.Text,
  abbreviatedName: IDL.Text,
});

export class F1TeamsService {
  constructor() {}

  //Queries

  async getF1Teams(dto: ListF1Teams): Promise<F1Teams> {
    const identityActor: any = await ActorFactory.createIdentityActor(
      authStore,
      process.env.BACKEND_CANISTER_ID ?? "",
    );
    const result = await identityActor.listF1Teams(dto);
    if (isError(result)) throw new Error("Failed to get F1 teams");
    return result.ok;
  }

  async getF1Team(dto: GetF1Team): Promise<F1Team> {
    const identityActor: any = await ActorFactory.createIdentityActor(
      authStore,
      process.env.BACKEND_CANISTER_ID ?? "",
    );
    const result = await identityActor.getF1Team(dto);
    if (isError(result)) throw new Error("Failed to get F1 team");
    return result.ok;
  }

  //Commands

  async addF1Team(dto: CreateF1Team) {
    let userIdentity: OptionIdentity;
    authStore.subscribe((auth) => (userIdentity = auth.identity));
    if (!userIdentity) return;

    const encoded = IDL.encode([AddF1Team_Idl], [dto]);

    const title = `Add ${dto.name} as F1 Team`;
    const summary = `Add ${dto.name} as F1 Team`;
    await this.createProposal({
      identity: userIdentity,
      functionId: 1_000n,
      payload: new Uint8Array(encoded),
      title,
      summary,
    });
  }

  async updateF1Team(dto: UpdateF1Team) {
    let userIdentity: OptionIdentity;
    authStore.subscribe((auth) => (userIdentity = auth.identity));
    if (!userIdentity) return;

    const encoded = IDL.encode([AddF1Team_Idl], [dto]);

    const title = `Update ${dto.name} F1 Team Information`;
    const summary = `Update ${dto.name} F1 Team Information`;
    await this.createProposal({
      identity: userIdentity,
      functionId: 2_000n,
      payload: new Uint8Array(encoded),
      title,
      summary,
    });
  }

  async createProposal({
    identity,
    functionId,
    payload,
    title,
    summary,
  }: {
    identity: OptionIdentity;
    functionId: bigint;
    payload: Uint8Array;
    title: string;
    summary: string;
  }) {
    if (!identity) throw new Error("No identity to propose with");

    const agent = await createAgent({
      identity,
      host: import.meta.env.VITE_AUTH_PROVIDER_URL,
      fetchRootKey: process.env.DFX_NETWORK === "local",
    });

    const { manageNeuron, listNeurons } = SnsGovernanceCanister.create({
      canisterId: Principal.fromText(
        process.env.SNS_GOVERNANCE_CANISTER_ID ?? "",
      ),
      agent,
    });

    const userNeurons = await listNeurons({
      principal: identity.getPrincipal(),
      limit: 10,
      beforeNeuronId: { id: [] },
    });
    if (userNeurons.length === 0) {
      throw new Error("No neurons found for this principal; cannot propose");
    }

    const neuronId = userNeurons[0].id[0];
    if (!neuronId) throw new Error("Neuron has no subaccount ID");

    const fn: ExecuteGenericNervousSystemFunction = {
      function_id: functionId,
      payload,
    };
    const command: Command = {
      MakeProposal: {
        title,
        url: "icgc.io/governance",
        summary,
        action: [{ ExecuteGenericNervousSystemFunction: fn }],
      },
    };

    return await manageNeuron({
      subaccount: neuronId.id,
      command: [command],
    });
  }
}
