<script lang="ts">
    import { f1TeamStore } from '$lib/stores/f1-team-store';
    import { scorecardStore } from '$lib/stores/scorecard-store';
    import type { TeamSelection } from "../../../../../declarations/backend/backend.did";

    import BrandPanel from '$lib/components/shared/brand-panel.svelte';
    import FullScreenSpinner from '$lib/components/shared/full-screen-spinner.svelte';
    import TeamList from '$lib/components/scorecard/team-list.svelte';

    let isLoading = $state(true);
    let loadingMessage = $state("Loading teams and selections...");
    let error = $state<string | null>(null);

    async function loadInitialData() {
        try {
            isLoading = true;
            error = null;
            
            await Promise.all([
                f1TeamStore.getF1Teams({ page: 1n }),
                scorecardStore.getPrediction({ year: 2025, raceId: 1 })
            ]);
            
        } catch (e) {
            error = "Failed to load team data";
            console.error("Loading error:", e);
        } finally {
            isLoading = false;
        }
    }

    async function handleUpdateSelection(updated: TeamSelection) {
        try {
            isLoading = true;
            loadingMessage = "Updating selection...";
            scorecardStore.update(selections => 
                selections.map(s => s.f1TeamId === updated.f1TeamId ? updated : s)
            );
        } catch (e) {
            error = "Failed to update selection";
            console.error("Update error:", e);
        } finally {
            isLoading = false;
        }
    }

    async function handleReorder(fromIndex: number, toIndex: number) {
        try {
            isLoading = true;
            loadingMessage = "Reordering teams...";
            scorecardStore.update(selections => {
                const newSelections = [...selections];
                const [moved] = newSelections.splice(fromIndex, 1);
                newSelections.splice(toIndex, 0, moved);
                return newSelections;
            });
        } catch (e) {
            error = "Failed to reorder teams";
            console.error("Reorder error:", e);
        } finally {
            isLoading = false;
        }
    }

    loadInitialData();
</script>

<BrandPanel title="SCORECARD" subTitle="Choose your racers for the next race">
    {#if error}
        <div class="p-4 mb-4 text-red-600 bg-red-100 rounded-lg">
            {error} - <button onclick={loadInitialData} class="underline">Try again</button>
        </div>
    {/if}

    {#if isLoading}
        <FullScreenSpinner message={loadingMessage} />
    {:else}
        <TeamList
            selections={$scorecardStore}
            onUpdateSelection={handleUpdateSelection}
            onReorder={handleReorder}
        />
        
        <div class="mt-8 text-center">
            <button 
                onclick={() => alert('Coming soon!')}
                class="px-6 py-3 font-medium text-white transition-colors bg-blue-600 rounded-lg hover:bg-blue-700"
            >
                Submit Predictions
            </button>
        </div>
    {/if}
</BrandPanel>