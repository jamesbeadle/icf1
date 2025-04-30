<script lang="ts">
    import { goto } from "$app/navigation";
    import { f1TeamStore } from "$lib/stores/f1-team-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { CreateF1Team } from "../../../../../../../declarations/backend/backend.did";

    import BrandPanel from "$lib/components/shared/brand-panel.svelte";
    import F1TeamDetail from "$lib/components/f1-team/f1-team-detail.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";

    let isLoading = $state(false);
    let loadingMessage = $state("");

    let teamName = $state("");
    let countryId = $state(0);
    let founded = $state(0n);

    async function submitF1Team() {
        if (!teamName) {
            alert("Please enter a team name");
            return;
        }

        if (countryId === 0) {
            alert("Please select a country");
            return;
        }

        if (founded === 0n) {
            alert("Please select a founding year");
            return;
        }

        const dto: CreateF1Team = {
            name: teamName,
            countryId,
            founded
        };

        try {
            isLoading = true;
            loadingMessage = "Creating F1 Team";
            await f1TeamStore.addF1Team(dto);
            toasts.addToast({type: 'success', message: 'F1 Team created successfully!', duration: 5000});
            goto("/f1-teams");
        } catch (error) {
            console.error("Failed to create F1 Team:", error);
            toasts.addToast({type: 'error', message: 'Failed to create F1 Team', duration: 5000});
        } finally {
            isLoading = false;
        }
    }
</script>

{#if isLoading}
    <LocalSpinner message={loadingMessage} />
{:else}
    <BrandPanel title="CREATE F1 TEAM" subTitle="">
        <form onsubmit={submitF1Team} class="space-y-6 text-black">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <F1TeamDetail 
                    bind:teamName 
                    bind:countryId 
                    bind:founded
                />
            </div>

            <div class="flex justify-end pt-6">
                <button
                    type="button"
                    class="px-4 py-2 mr-3 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-BrandForest"
                    onclick={() => goto("/f1-race-tracks")}
                >
                    Cancel
                </button>
                <button
                    type="submit"
                    class="inline-flex justify-center px-4 py-2 text-sm font-medium text-white border border-transparent rounded-md shadow-sm bg-BrandForest hover:bg-BrandForest/80 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-BrandForest"
                >
                    Create Race Track
                </button>
            </div>
        </form>
    </BrandPanel>
{/if}