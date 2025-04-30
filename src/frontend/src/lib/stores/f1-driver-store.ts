import type {
  GetF1Driver,
  ListF1Drivers,
  F1Driver,
  F1Drivers,
  CreateF1Driver,
  UpdateF1Driver,
} from "../../../../declarations/backend/backend.did";
import { F1DriverService } from "$lib/services/f1-driver-service";
import { writable } from "svelte/store";

function createF1DriverStore() {
  const { subscribe, set } = writable<F1Driver[]>([]);

  async function getF1Drivers(dto: ListF1Drivers): Promise<F1Drivers> {
    return new F1DriverService().getF1Drivers(dto);
  }

  async function getF1Driver(dto: GetF1Driver): Promise<F1Driver> {
    return new F1DriverService().getF1Driver(dto);
  }

  async function addF1Driver(dto: CreateF1Driver): Promise<void> {
    return new F1DriverService().addF1Driver(dto);
  }

  async function updateF1Driver(dto: UpdateF1Driver): Promise<void> {
    return new F1DriverService().addF1Driver(dto);
  }

  return {
    subscribe,
    set,
    getF1Drivers,
    getF1Driver,
    addF1Driver,
    updateF1Driver,
  };
}

export const f1DriverStore = createF1DriverStore();
