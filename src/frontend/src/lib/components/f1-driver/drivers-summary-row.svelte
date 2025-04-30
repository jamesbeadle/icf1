<script lang="ts">
    import { goto } from "$app/navigation";
    import type { F1DriverSummary } from "../../../../../declarations/backend/backend.did";
    import { getFlagComponent } from "$lib/utils/helpers";

    interface Props {
        f1Driver: F1DriverSummary;
    }

    let { f1Driver }: Props = $props();
    const Flag = getFlagComponent(f1Driver.nationality);

    function selectDriver() {
        goto(`/f1-drivers/${f1Driver.f1DriverId}`);
    }
</script>

<button 
    onclick={selectDriver}
    class="w-full p-4 text-left transition-colors duration-200 border-b hover:bg-gray-50"
>
    <div class="flex flex-col space-y-3 sm:space-y-0 sm:flex-row sm:items-center sm:justify-between">
        <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2">
                <h3 class="text-lg font-medium truncate text-BrandForest">
                    {f1Driver.firstName} {f1Driver.lastName}
                </h3>
                {#if Flag}
                    <Flag class="w-5 h-5" />
                {/if}
            </div>
        </div>
    </div>
</button>