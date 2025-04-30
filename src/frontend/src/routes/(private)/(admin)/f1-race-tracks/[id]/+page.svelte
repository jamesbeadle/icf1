<script lang="ts">
    import { onMount } from "svelte";
    import { page } from "$app/state";
    import { f1RaceTrackStore } from "$lib/stores/f1-race-track-store";
    import type { GetRaceTrack, RaceTrack } from "../../../../../../../declarations/backend/backend.did";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";
    import { getImageURL } from "$lib/utils/helpers";

    let isLoading = $state(true);
    let raceTrackId: number;
    let raceTrack: RaceTrack | null = $state(null);

    onMount(async () => {
        raceTrackId = Number(page.params.id);
        let dto: GetRaceTrack = { raceTrackId };
        raceTrack = await f1RaceTrackStore.getF1RaceTrack(dto);
        isLoading = false;
    });

</script>

{#if isLoading}
    <LocalSpinner />
{:else}
    <div class="flex flex-row">
        <div class="flex flex-col w-1/2">
            <p>RACE TRACK</p>
            <p>{raceTrack?.raceTrackId}</p> 
        </div>
    </div>
{/if}