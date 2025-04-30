<script lang="ts">
    import { goto } from "$app/navigation";
    import { f1RaceStore } from "$lib/stores/f1-race-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { CreateRace } from "../../../../../../../declarations/backend/backend.did";

    import BrandPanel from "$lib/components/shared/brand-panel.svelte";
    import F1RaceDetail from "$lib/components/f1-race/f1-race-detail.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";

    let isLoading = $state(false);
    let loadingMessage = $state("");

    let raceName = $state("");

    async function submitF1Driver() {
        if (!raceName) {
            alert("Please enter a race name");
            return;
        }

        const dto: CreateRace = {
            name: raceName,
        };

        try {
            isLoading = true;
            loadingMessage = "Creating F1 Race";
            await f1RaceStore.addF1Race(dto);
            toasts.addToast({type: 'success', message: 'F1 Race created successfully!', duration: 5000});
            goto("/f1-races");
        } catch (error) {
            console.error("Failed to create F1 Driver:", error);
            toasts.addToast({type: 'error', message: 'Failed to create F1 Driver', duration: 5000});
        } finally {
            isLoading = false;
        }
    }
</script>

{#if isLoading}
    <LocalSpinner message={loadingMessage} />
{:else}
    <BrandPanel title="CREATE F1 DRIVER" subTitle="">
        <form onsubmit={submitF1Driver} class="space-y-6 text-black">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <F1RaceDetail 
                    bind:raceName 
                />
            </div>

            <div class="flex justify-end pt-6">
                <button
                    type="button"
                    class="px-4 py-2 mr-3 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-BrandForest"
                    onclick={() => goto("/f1-races")}
                >
                    Cancel
                </button>
                <button
                    type="submit"
                    class="inline-flex justify-center px-4 py-2 text-sm font-medium text-white border border-transparent rounded-md shadow-sm bg-BrandForest hover:bg-BrandForest/80 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-BrandForest"
                >
                    Create Race
                </button>
            </div>
        </form>
    </BrandPanel>
{/if}