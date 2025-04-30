import { F1TeamsService } from "$lib/services/f1-team-service";
import type {
  CreateF1Team,
  GetF1Team,
  ListF1Teams,
  F1Team,
  F1Teams,
  UpdateF1Team,
} from "../../../../declarations/backend/backend.did";
import { writable } from "svelte/store";

function createF1TeamStore() {
  const { subscribe, set, update } = writable<F1Team[]>([]);

  async function getF1Teams(dto: ListF1Teams): Promise<F1Teams> {
    return await new F1TeamsService().getF1Teams(dto);
  }

  async function getF1Team(dto: GetF1Team): Promise<F1Team> {
    return await new F1TeamsService().getF1Team(dto);
  }

  async function addF1Team(dto: CreateF1Team): Promise<void> {
    return await new F1TeamsService().addF1Team(dto);
  }

  async function updateF1Team(dto: UpdateF1Team): Promise<void> {
    return await new F1TeamsService().updateF1Team(dto);
  }

  return {
    subscribe,
    set,
    update,
    getF1Team,
    getF1Teams,
    addF1Team,
    updateF1Team,
  };
}
export const f1TeamStore = createF1TeamStore();
