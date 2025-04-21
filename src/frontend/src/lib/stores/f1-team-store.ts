import { F1TeamService } from "$lib/services/f1-team-service";
import type {
  CreateF1Team,
  GetF1Team,
  GetF1Teams,
  F1Team,
  F1Teams,
  UpdateF1Team,
} from "../../../../declarations/backend/backend.did";

function createF1TeamStore() {
  async function getF1Teams(dto: GetF1Teams): Promise<F1Teams> {
    return await new F1TeamsService().getF1Teams(dto);
  }

  async function getF1Team(dto: GetGF1Teame): Promise<F1Teame> {
    return await new F1TeamsService().getF1Team(dto);
  }

  async function addF1Team(dto: CreateF1Team): Promise<void> {
    return await new F1TeamsService().addF1Team(dto);
  }

  async function updateF1Team(dto: UpdateF1Team): Promise<void> {
    return await new F1TeamsService().updateF1Team(dto);
  }

  return {
    getF1Team,
    getF1Teams,
    addF1Team,
    updateF1Team,
  };
}
export const f1TeamStore = createF1TeamStore();
