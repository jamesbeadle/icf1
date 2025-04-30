<script lang="ts">
    import { onMount } from "svelte";
    import { goto } from "$app/navigation";
    import { f1RaceStore } from "$lib/stores/f1-race-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { Races, ListRaces } from "../../../../../../declarations/backend/backend.did";
    
    import ListViewPanel from "$lib/components/shared/list-view-panel.svelte";
    import PaginationRow from "$lib/components/shared/pagination-row.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";
    import F1RaceSummaryRow from "$lib/components/f1-race/f1-race-summary-row.svelte";

    let isLoading = true;
    let races: Races | null = null;
    let page = 1n;
    let totalPages = 1n; 
    let pageSize = 10n;

    onMount( async () => {
        loadRaces();
    });

    function createNew(){
        goto('/f1-races/create')
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

            let dto: ListRaces = { page };

            races = await f1RaceStore.getF1Races(dto);
            
            if (races?.totalEntries) {
                totalPages = BigInt(Math.ceil(Number(races.totalEntries) / Number(pageSize)));
            }
        } catch {
            toasts.addToast({type: 'error', message: 'Error loading F1 drivers.'});
            races = null;
        } finally {
            isLoading = false;
        }
    }

</script>

{#if isLoading}
    <LocalSpinner />
{:else}
    <ListViewPanel title="F1 Races" buttonTitle="ADD F1 RACE" buttonCallback={createNew}>
        {#if races}
            {#if races.entries.length > 0}
                {#each races?.entries! as race}
                    <F1RaceSummaryRow {race} />
                {/each}
                <PaginationRow {changePage} {page} {pageSize} total={races.totalEntries} typeName='races' />
            {:else}
                <p>No F1 Races found.</p>
            {/if}                
        {:else}
            <p>Error loading F1 Races.</p>
        {/if}
    </ListViewPanel>
{/if}