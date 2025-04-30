<script lang="ts">
    import { onMount } from "svelte";
    import Layout from "../../+layout.svelte";
    import { page } from "$app/state";
    import { f1RaceStore } from "$lib/stores/f1-race-store";
    import type { GetRace, Race } from "../../../../../../../declarations/backend/backend.did";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";
    import { getImageURL } from "$lib/utils/helpers";

    let isLoading = $state(true);
    let raceId: number;
    let race: Race | null = $state(null);

    onMount(async () => {
        raceId = Number(page.params.id);
        let dto: GetRace = { raceId };
        race = await f1RaceStore.getF1Race(dto);
        isLoading = false;
    });

</script>

{#if isLoading}
    <LocalSpinner />
{:else}
    <div class="flex flex-row">
        <div class="flex flex-col w-1/2">
            <p>RACE</p>
            <p>{race?.raceId}</p> 
        </div>
    </div>
{/if}