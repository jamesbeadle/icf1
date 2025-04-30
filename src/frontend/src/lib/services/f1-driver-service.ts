import { isError } from "$lib/utils/helpers";
import { ActorFactory } from "$lib/utils/actor.factory";
import type {
  GetF1Driver,
  ListF1Drivers,
  F1Driver,
  F1Drivers,
  UpdateF1Driver,
  CreateF1Driver,
} from "../../../../declarations/backend/backend.did";
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

const AddF1Driver_Idl = IDL.Record({
  firstName: IDL.Text,
  lastName: IDL.Text,
  nationality: IDL.Text,
  f1TeamId: IDL.Text,
});

export class F1DriverService {
  constructor() {}

  //Getters

  async getF1Drivers(dto: ListF1Drivers): Promise<F1Drivers> {
    try {
      const identityActor: any = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );

      let result = await identityActor.ListF1Drivers(dto);

      if (isError(result)) {
        console.error("Error Fetching F1 Drivers", result);
      }

      return result.ok;
    } catch (error) {
      console.error("Error Fetching F1 Drivers", error);
      throw error;
    }
  }

  async getF1Driver(dto: GetF1Driver): Promise<F1Driver> {
    try {
      const identityActor: any = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );

      let result = await identityActor.getF1Driver(dto);

      if (isError(result)) {
        console.error("Error Fetching F1 Driver", result);
      }

      return result.ok;
    } catch (error) {
      console.error("Error Fetching F1 Driver", error);
      throw error;
    }
  }

  async addF1Driver(dto: CreateF1Driver) {
    let userIdentity: OptionIdentity;
    authStore.subscribe((auth) => (userIdentity = auth.identity));
    if (!userIdentity) return;

    const encoded = IDL.encode([AddF1Driver_Idl], [dto]);

    const title = `Update ${dto.firstName} ${dto.lastName}  F1 Driver Information`;
    const summary = `Update ${dto.firstName} ${dto.lastName}  F1 Driver Information`;
    await this.createProposal({
      identity: userIdentity,
      functionId: 1_000n,
      payload: new Uint8Array(encoded),
      title,
      summary,
    });
  }

  async updateF1Driver(dto: UpdateF1Driver) {
    let userIdentity: OptionIdentity;
    authStore.subscribe((auth) => (userIdentity = auth.identity));
    if (!userIdentity) return;

    const encoded = IDL.encode([AddF1Driver_Idl], [dto]);

    const title = `Update ${dto.firstName} ${dto.lastName}  F1 Driver Information`;
    const summary = `Update ${dto.firstName} ${dto.lastName}  F1 Driver Information`;
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
