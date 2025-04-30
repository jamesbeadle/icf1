import { isError } from "$lib/utils/helpers";
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
import type { GetRaceTrack, RaceTrack, RaceTracks, ListRaceTracks, CreateRaceTrack } from "../../../../declarations/backend/backend.did";

const AddF1RaceTrack_Idl = IDL.Record({
    name: IDL.Text,
    countryId: IDL.Text,
    opened: IDL.Text,
});

export class F1RaceTrackService {
    constructor() {}

    async getF1RaceTracks(dto: ListRaceTracks): Promise<RaceTracks> {
        try {
          const identityActor: any = await ActorFactory.createIdentityActor(
            authStore,
            process.env.BACKEND_CANISTER_ID ?? "",
          );
    
          let result = await identityActor.ListRaceTracks(dto);
    
          if (isError(result)) {
            console.error("Error Fetching F1 Race Tracks", result);
          }
    
          return result.ok;
        } catch (error) {
          console.error("Error Fetching F1 Race Tracks", error);
          throw error;
        }
    }

    async getF1RaceTrack(dto: GetRaceTrack): Promise<RaceTrack> {
        try {
          const identityActor: any = await ActorFactory.createIdentityActor(
            authStore,
            process.env.BACKEND_CANISTER_ID ?? "",
          );
    
          let result = await identityActor.getRaceTrack(dto);
    
          if (isError(result)) {
            console.error("Error Fetching F1 Race Track", result);
          }
    
          return result.ok;
        } catch (error) {
          console.error("Error Fetching F1 Race Track", error);
          throw error;
        }
    }

    async addF1RaceTrack(dto: CreateRaceTrack) {
        let userIdentity: OptionIdentity;
        authStore.subscribe((auth) => (userIdentity = auth.identity));
        if (!userIdentity) return;
    
        const encoded = IDL.encode([AddF1RaceTrack_Idl], [dto]);
    
        const title = `Create ${dto.name} F1 Race Track Information`;
        const summary = `Create ${dto.name} F1 Race Track Information`;
        await this.createProposal({
          identity: userIdentity,
          functionId: 1_000n,
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
        //TODO: UPDATE URL
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