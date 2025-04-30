import { LeaderboardService } from "$lib/services/leaderboard-service";
import type {
  GetFantasyLeaderboard,
  FantasyLeaderboard,
} from "../../../../declarations/backend/backend.did";
import { writable } from "svelte/store";

function createLeaderboardStore() {
  const { subscribe, set } = writable<FantasyLeaderboard>();

  async function getLeaderboard(
    dto: GetFantasyLeaderboard,
  ): Promise<FantasyLeaderboard> {
    return new LeaderboardService().getLeaderboard(dto);
  }

  return {
    getLeaderboard,
    subscribe,
    set,
  };
}

export const leaderboardStore = createLeaderboardStore();
