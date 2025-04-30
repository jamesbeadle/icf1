<script lang="ts">
    import { MAX_BONUSES } from "$lib/types/constants";
    import { bonusToString } from "$lib/utils/scorecard.helpers";
    import type { F1Team, BonusType, TeamSelection } from "../../../../../declarations/backend/backend.did";
    import { toasts } from "$lib/stores/toasts-store";

    import TrafficLight from "./traffic-light.svelte";
    import LocalSpinner from "../shared/local-spinner.svelte";

    interface Props {
        team: F1Team;
        selection: TeamSelection
        allBonuses: BonusType[];
        usedBonuses: BonusType[];
        onUpdateSelection: (selection: TeamSelection) => void;
        onMoveUp: (() => void) | undefined;
        onMoveDown: (() => void) | undefined;
    }

    let { team, selection, allBonuses, usedBonuses, onUpdateSelection, onMoveUp, onMoveDown }: Props = $props();
    let isLoading = $state(false);
    let loadingMessage = $state("");

    const availableBonuses = $derived(
        allBonuses.filter(bonus => {
            const bonusKey = bonusToString(bonus);
            return !usedBonuses.some(used => bonusToString(used) === bonusKey);
        })
    );
    //TODO: Make sure this works
    let leadDriver = $derived(team.drivers.find(d => d.f1DriverId === selection.leadDriver) ?? {firstName: 'Unknown', lastName: 'Driver', nationality: 'N/A', f1DriverId: ''});
    let secondDriver = $derived(team.drivers.find(d => d.f1DriverId === selection.secondDriver) ?? {firstName: 'Unknown', lastName: 'Driver', nationality: 'N/A', f1DriverId: ''});
    
    async function handleAddBonus(driverType: 'lead' | 'second', bonus: BonusType) {
        if (isLoading) return;
        
        try {
            isLoading = true;
            loadingMessage = "Adding bonus";
            
            const currentBonuses = selection[driverType === 'lead' ? 'leadDriverBonuses' : 'secondDriverBonuses'];
            const bonusKey = bonusToString(bonus);
            
            if (currentBonuses.some(b => bonusToString(b) === bonusKey)) return;
            if (currentBonuses.length >= MAX_BONUSES) return;

            const updated = {
                ...selection,
                [driverType === 'lead' ? 'leadDriverBonuses' : 'secondDriverBonuses']: [...currentBonuses, bonus]
            };
            
            await onUpdateSelection(updated);
        } catch (e) {
            toasts.addToast({
                message: "Failed to add bonus",
                type: "error",
                duration: 5000
            });
            console.error(e);
        } finally {
            isLoading = false;
        }
    }

    async function swapDrivers() {
        if (isLoading) return;
        
        try {
            isLoading = true;
            loadingMessage = "Swapping drivers";
            
            const updatedSelection = {
                ...selection,
                leadDriver: selection.secondDriver,
                secondDriver: selection.leadDriver,
                leadDriverBonuses: selection.secondDriverBonuses,
                secondDriverBonuses: selection.leadDriverBonuses
            };
            
            await onUpdateSelection?.(updatedSelection);
        } catch (e) {
            toasts.addToast({
                message: "Failed to swap drivers",
                type: "error",
                duration: 5000
            });
            console.error(e);
        } finally {
            isLoading = false;
        }
    } 
</script>

{#if isLoading}
    <LocalSpinner message={loadingMessage} />
{:else}
    <div class="p-4 mb-4 transition-all bg-white border border-gray-200 rounded-lg shadow-sm team-card hover:shadow-md">
        <div class="flex items-center justify-between mb-3">
            <h3 class="text-lg font-bold text-gray-900">{team.name}</h3>
            
            <div class="flex gap-2" class:hidden={!onMoveUp && !onMoveDown}>
                {#if onMoveUp}
                    <button 
                        onclick={onMoveUp}
                        class="p-1 rounded hover:bg-gray-100"
                        aria-label="Move team up"
                    >
                        ↑
                    </button>
                {/if}
                {#if onMoveDown}
                    <button 
                        onclick={onMoveDown}
                        class="p-1 rounded hover:bg-gray-100"
                        aria-label="Move team down"
                    >
                        ↓
                    </button>
                {/if}
            </div>
        </div>
    
        <div class="flex items-center justify-between gap-4">
            <div class="flex flex-col items-center flex-1 gap-2">
                <TrafficLight 
                    bonuses={selection.leadDriverBonuses}
                    {availableBonuses}
                    onAddBonus={(b) => handleAddBonus('lead', b)}
                />
                <div class="text-center driver-info">
                    <div class="font-medium text-gray-900">
                        {leadDriver?.firstName} {leadDriver?.lastName}
                    </div>
                    <div class="text-xs text-gray-500">
                        {leadDriver?.nationality}
                    </div>
                </div>
            </div>
    
            <button
                onclick={swapDrivers}
                class="p-2 transition-colors bg-gray-100 rounded-full swap-button hover:bg-gray-200"
                aria-label="Swap lead and secondary drivers"
            >
                ⇄ Swap
            </button>
    
            <div class="flex flex-col items-center flex-1 gap-2">
                <TrafficLight 
                    bonuses={selection.secondDriverBonuses}
                    {availableBonuses}
                    onAddBonus={(b) => handleAddBonus('second', b)}
                />
                <div class="text-center driver-info">
                    <div class="font-medium text-gray-900">
                        {secondDriver?.firstName} {secondDriver?.lastName}
                    </div>
                    <div class="text-xs text-gray-500">
                        {secondDriver?.nationality}
                    </div>
                </div>
            </div>
        </div>
    </div>
{/if}
  
<style>
    .team-card {
      min-width: 320px;
    }
    
    .swap-button {
      min-width: 40px;
    }
    
    @media (max-width: 640px) {
      .team-card {
        min-width: 280px;
      }
    }
</style>