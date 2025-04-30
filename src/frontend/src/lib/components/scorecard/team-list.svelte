<script lang="ts">
    import { ALL_BONUSES } from "$lib/utils/scorecard.helpers";
    import type { F1Team, TeamSelection, BonusType } from "../../../../../declarations/backend/backend.did";
    import { f1TeamStore } from "$lib/stores/f1-team-store";

    import TeamCard from "./team-card.svelte";
    import LocalSpinner from "../shared/local-spinner.svelte";

    interface Props {
        selections: TeamSelection[];
        onUpdateSelection: (updated: TeamSelection) => Promise<void>;
        onReorder: (fromIndex: number, toIndex: number) => Promise<void>;
    }

    let { selections, onUpdateSelection, onReorder }: Props = $props();

    const teams = $derived($f1TeamStore);
    let isLoading = $state(false);
    let loadingMessage = $state("Loading teams");

    const usedBonuses = $derived(selections.flatMap(s => 
        [...s.leadDriverBonuses, ...s.secondDriverBonuses]
    ));

    async function moveTeamUp(index: number) {
        if (index <= 0) return;
        await onReorder(index, index - 1);
    }

    async function moveTeamDown(index: number) {
        if (index >= selections.length - 1) return;
        await onReorder(index, index + 1);
    }
</script>

{#if isLoading}
    <LocalSpinner message={loadingMessage} />
{:else}
    <div class="space-y-4 team-list">
        {#each selections as selection, index (selection.f1TeamId)}
            {@const team = teams.find(t => t.f1TeamId === selection.f1TeamId)}
            {#if team}
                <TeamCard
                    {team}
                    {selection}
                    allBonuses={ALL_BONUSES}
                    {usedBonuses}
                    onUpdateSelection={onUpdateSelection}
                    onMoveUp={index > 0 ? () => moveTeamUp(index) : undefined}
                    onMoveDown={index < selections.length - 1 ? () => moveTeamDown(index) : undefined}
                />
            {:else}
                <div class="p-4 text-red-500 rounded-lg bg-red-50">
                    Team not found for selection {selection.f1TeamId}
                </div>
            {/if}
        {/each}
    </div>
{/if}
  
<style>
    .team-list {
        min-width: min(100%, 800px);
    }
</style>