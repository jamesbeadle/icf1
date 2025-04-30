<script lang="ts">
    import { MAX_BONUSES } from "$lib/types/constants";
    import { bonusToString } from "$lib/utils/scorecard.helpers";
    import type { BonusType } from "../../../../../declarations/backend/backend.did";

    import BonusSelector from "./bonus-selector.svelte";
    
    interface Props {
        bonuses: BonusType[];
        availableBonuses: BonusType[];
        onAddBonus: (bonus: BonusType) => void;
    }

    let { bonuses, availableBonuses, onAddBonus }: Props = $props();

    let isBonusSelectorOpen = $state(false);

</script>

<div class="flex flex-wrap gap-2">
    {#each bonuses as bonus}
        {@const bonusKey = bonusToString(bonus)}
        <div 
            class="px-3 py-1 text-sm bg-gray-200 rounded-full"
            aria-label={`Selected bonus: ${bonusKey}`}
        >
            {bonusKey}
        </div>
    {/each}

    {#if bonuses.length < MAX_BONUSES}
        <button
            onclick={() => isBonusSelectorOpen = true}
            onkeydown={(e) => e.key === 'Enter' && (isBonusSelectorOpen = true)}
            class="flex items-center justify-center w-8 h-8 bg-gray-300 rounded-full hover:bg-gray-400"
            aria-label="Add new bonus"
        >
            +
        </button>
    {/if}
  </div>

{#if isBonusSelectorOpen}
    <BonusSelector
        {availableBonuses}
        currentDriverBonuses={bonuses}
        onSelect={onAddBonus}
        onClose={() => isBonusSelectorOpen = false}
    />
{/if}