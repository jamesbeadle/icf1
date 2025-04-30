<script lang="ts">
    import { bonusToString } from "$lib/utils/scorecard.helpers";
    import type { BonusType } from "../../../../../declarations/backend/backend.did";
    import { MAX_BONUSES } from "$lib/types/constants";
    import Modal from "../shared/modal.svelte";

    interface Props {
       availableBonuses: BonusType[];
       currentDriverBonuses: BonusType[];
       onSelect: (bonus: BonusType) => void;
       onClose: () => void;
    }

    let { availableBonuses, currentDriverBonuses, onSelect, onClose }: Props = $props();

    const bonusLabels = {
        DidNotFinish: 'DNF',
        OnPole: 'Pole Position',
        Lapped: 'Lapped',
        FirstOut: 'First Out',
        WinsRace: 'Race Winner',
        FastestLap: 'Fastest Lap'
    };

    function handleSelect(bonus: BonusType) {
        if (currentDriverBonuses.length >= MAX_BONUSES && 
            !currentDriverBonuses.some(b => bonusToString(b) === bonusToString(bonus))) {
        return;
        }
        onSelect(bonus);
    }

    //TODO: COLORS
</script>

<Modal title="Select Bonus" onClose={onClose} >
    <div class="grid grid-cols-2 gap-3 p-2">
        {#each availableBonuses as bonus}
            {@const bonusKey = bonusToString(bonus)}
            {@const label = bonusLabels[bonusKey as keyof typeof bonusLabels]}
            <button
                onclick={() => handleSelect(bonus)}
                onkeydown={(e) => e.key === 'Enter' && handleSelect(bonus)}
                disabled={currentDriverBonuses.some(b => bonusToString(b) === bonusKey)}
                class="p-3 transition-colors border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100"
                aria-label={`Select ${label} bonus`}
                aria-disabled={currentDriverBonuses.some(b => bonusToString(b) === bonusKey)}
            >
                {label}
            </button>
        {/each}
    </div>
</Modal>