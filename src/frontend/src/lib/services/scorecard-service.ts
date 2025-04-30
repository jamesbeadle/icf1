import { ActorFactory } from "$lib/utils/actor.factory";
import { isError } from "$lib/utils/helpers";
import { authStore } from "$lib/stores/auth-store";
import type {
  GetPrediction,
  GetRaceCard,
  Prediction,
  Predictions,
  SubmitPrediction,
  ListPredictions,
  BonusType,
  F1DriverId,
  F1TeamId,
} from "../../../../declarations/backend/backend.did";

export class ScorecardService {
  constructor() {}

  newPrediction = {
    leadDriverBonuses: Array<BonusType>(),
    secondDriver: 0,
    secondDriverBonuses: Array<BonusType>(),
    leadDriver: 0,
    f1TeamId: 0,
    fastestTeamSelectionIndex: 0,
  };

  async getPrediction(dto: GetPrediction): Promise<Prediction> {
    try {
      const identityActor: any = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );

      let result = await identityActor.getPrediction(dto);

      if (isError(result)) {
        console.error("Error Getting Prediction", result);
      }

      return result.ok;
    } catch (error) {
      console.error("Error Getting Prediction", error);
      throw error;
    }
  }

  async getScorecard(dto: GetRaceCard): Promise<Prediction> {
    try {
      const identityActor: any = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );

      let result = await identityActor.getRaceCard(dto);

      if (isError(result)) {
        console.error("Error Getting Score Card", result);
      }

      return result.ok;
    } catch (error) {
      console.error("Error Getting Score Card", error);
      return this.newPrediction;
    }
  }

  async listPredictions(dto: ListPredictions): Promise<Predictions> {
    try {
      const identityActor: any = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );

      let result = await identityActor.listPredictions(dto);

      if (isError(result)) {
        console.error("Error Getting Predictions", result);
      }

      return result.ok;
    } catch (error) {
      console.error("Error Getting Predictions", error);
      return this.newPrediction;
    }
  }

  async submitPrediction(dto: SubmitPrediction): Promise<any> {
    try {
      const identityActor: any = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );

      let result = await identityActor.submitPrediction(dto);

      if (isError(result)) {
        console.error("Error Submitting Prediction", result);
      }

      return result.ok;
    } catch (error) {
      console.error("Error Submitting Prediction", error);
      throw error;
    }
  }
}
