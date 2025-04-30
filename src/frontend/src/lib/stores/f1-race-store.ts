import type {
  GetRace,
  ListRaces,
  Race,
  Races,
  CreateRace,
  UpdateRaceStage,
} from "../../../../declarations/backend/backend.did";
import { F1RaceService } from "$lib/services/f1-race-service";
import { writable } from "svelte/store";

function createF1RaceStore() {
  const { subscribe, set } = writable<Race[]>([]);

  async function getF1Races(dto: ListRaces): Promise<Races> {
    return new F1RaceService().getF1Races(dto);
  }

  async function getF1Race(dto: GetRace): Promise<Race> {
    return new F1RaceService().getF1Race(dto);
  }

  async function addF1Race(dto: CreateRace): Promise<void> {
    return new F1RaceService().addF1Race(dto);
  }

  async function updateF1RaceStage(dto: UpdateRaceStage): Promise<void> {
    return new F1RaceService().updateF1RaceStage(dto);
  }

  return {
    subscribe,
    set,
    getF1Races,
    getF1Race,
    addF1Race,
    updateF1RaceStage,
  };
}

export const f1RaceStore = createF1RaceStore();
