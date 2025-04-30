<script lang="ts">
    import { onMount } from "svelte";
    import { goto } from "$app/navigation";
    import { f1RaceTrackStore } from "$lib/stores/f1-race-track-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { RaceTracks, ListRaceTracks } from "../../../../../../declarations/backend/backend.did";
    
    import ListViewPanel from "$lib/components/shared/list-view-panel.svelte";
    import PaginationRow from "$lib/components/shared/pagination-row.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";
    import F1RaceTrackSummaryRow from "$lib/components/f1-race-track/f1-race-track-summary-row.svelte";

    let isLoading = true;
    let raceTracks: RaceTracks | null = null;
    let page = 1n;
    let totalPages = 1n; 
    let pageSize = 10n;

    onMount( async () => {
        loadRaces();
    });

    function createNew(){
        goto('/f1-race-tracks/create')
    }

    async function changePage(delta: bigint) {
        const newPage = page + delta;
        if (newPage >= 1 && newPage <= Number(totalPages)) {
            page = BigInt(newPage);
            await loadRaces();
        }
    }

    async function loadRaces() {
        isLoading = true;
        try {

            let dto: ListRaceTracks = { page };

            raceTracks = await f1RaceTrackStore.getF1RaceTracks(dto);
            
            if (raceTracks?.totalEntries) {
                totalPages = BigInt(Math.ceil(Number(raceTracks.totalEntries) / Number(pageSize)));
            }
        } catch {
            toasts.addToast({type: 'error', message: 'Error loading F1 drivers.'});
            raceTracks = null;
        } finally {
            isLoading = false;
        }
    }

</script>

{#if isLoading}
    <LocalSpinner />
{:else}
    <ListViewPanel title="F1 Race Tracks" buttonTitle="ADD F1 RACE TRACK" buttonCallback={createNew}>
        {#if raceTracks}
            {#if raceTracks.entries.length > 0}
                {#each raceTracks?.entries! as raceTrack}
                    <F1RaceTrackSummaryRow {raceTrack} />
                {/each}
                <PaginationRow {changePage} {page} {pageSize} total={raceTracks.totalEntries} typeName='raceTracks' />
            {:else}
                <p>No F1 Race Tracks found.</p>
            {/if}                
        {:else}
            <p>Error loading F1 Race Tracks.</p>
        {/if}
    </ListViewPanel>
{/if}