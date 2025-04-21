import { isError } from "$lib/utils/helpers";
import { ActorFactory } from "$lib/utils/actor.factory";
import type {
  F1DriverSummaries,
  GetF1DriverSummaries,
  GetF1Driver,
  GetF1Drivers,
  F1Driver,
  F1Drivers,
} from "../../../../declarations/backend/backend.did";
import { authStore } from "$lib/stores/auth-store";

export class F1DriverService {
  constructor() {}

  //Getters

  async getF1Drivers(dto: GetF1Drivers): Promise<F1Drivers> {
    try {
      const identityActor: any = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );

      let result = await identityActor.getF1Drivers(dto);

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

  async getF1DriverSummaries(
    dto: GetF1DriverSummaries,
  ): Promise<F1DriverSummaries> {
    try {
      const identityActor: any = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );

      let result = await identityActor.getF1DriverSummaries(dto);

      if (isError(result)) {
        console.error("Error Fetching F1 Driver Summaries", result);
      }

      return result.ok;
    } catch (error) {
      console.error("Error Fetching F1 Driver Summaries", error);
      throw error;
    }
  }
}
