import { F1RaceTrackService } from "$lib/services/f1-race-track-service";
import { writable } from "svelte/store";
import type { GetRaceTrack, RaceTrack, RaceTracks, ListRaceTracks, CreateRaceTrack } from "../../../../declarations/backend/backend.did";

function createF1RaceTrackStore() {
    const { subscribe, set } = writable<RaceTrack[]>([]);

    async function getF1RaceTracks(dto: ListRaceTracks): Promise<RaceTracks> {
        return new F1RaceTrackService().getF1RaceTracks(dto);
    }

    async function getF1RaceTrack(dto: GetRaceTrack): Promise<RaceTrack> {
        return new F1RaceTrackService().getF1RaceTrack(dto);
    }

    async function addF1RaceTrack(dto: CreateRaceTrack): Promise<void> {
        return new F1RaceTrackService().addF1RaceTrack(dto);
    }

    return {
        subscribe,
        set,
        getF1RaceTracks,
        getF1RaceTrack,
        addF1RaceTrack,
    };
}

export const f1RaceTrackStore = createF1RaceTrackStore();
