<script lang="ts">
    import { goto } from "$app/navigation";
    import type { F1TeamSummary } from "../../../../../declarations/backend/backend.did";

    interface Props {
        f1Team: F1TeamSummary;
    }

    let { f1Team }: Props = $props();

    function selectF1Team() {
        goto(`/f1-teams/${f1Team.f1TeamId}`);
    }
</script>

<button 
    onclick={selectF1Team}
    class="w-full p-4 text-left transition-colors duration-200 border-b hover:bg-gray-50"
>
    <div class="flex flex-col space-y-3 sm:space-y-0 sm:flex-row sm:items-center sm:justify-between">
        <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2">
                <h3 class="text-lg font-medium truncate text-BrandForest">
                    {f1Team.name}
                </h3>
            </div>
        </div>
        <div class="flex items-center space-x-6">
            <div class="flex items-center space-x-2 sm:flex-col sm:items-center sm:space-x-0">
                <span class="text-sm font-semibold text-BrandDarkGray">Team ID</span>
                <p class="text-lg condensed text-BrandForest sm:mt-1">#{f1Team.f1TeamId}</p>
            </div>
        </div>
    </div>
</button>
    