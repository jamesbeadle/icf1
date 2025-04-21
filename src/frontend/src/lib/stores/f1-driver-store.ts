import type {
  F1DriverSummaries,
  GetF1DriverSummaries,
  GetF1Driver,
  GetF1Driverss,
  F1Driver,
  F1Drivers,
} from "../../../../declarations/backend/backend.did";
import { F1DriverService } from "$lib/services/f1-driver-service";

function createF1DriverStore() {
  async function getF1Drivers(dto: GetF1Drivers): Promise<F1Drivers> {
    return new F1DriverService().getF1Drivers(dto);
  }

  async function getF1Driver(dto: GetF1Driver): Promise<F1Driver> {
    return new F1DriverService().getF1Drvier(dto);
  }

  async function getF1DriverSummaries(
    dto: GetF1DriverSummaries,
  ): Promise<F1DriverSummaries> {
    return new F1DriverService().getF1DriverSummaries(dto);
  }

  return {
    getF1Drivers,
    getF1Driver,
    getF1DriverSummaries,
  };
}

export const f1DriverStore = createF1DriverStore();
