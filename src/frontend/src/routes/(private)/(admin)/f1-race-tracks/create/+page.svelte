<script lang="ts">
    import { goto } from "$app/navigation";
    import { f1RaceTrackStore } from "$lib/stores/f1-race-track-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { CreateRaceTrack } from "../../../../../../../declarations/backend/backend.did";

    import BrandPanel from "$lib/components/shared/brand-panel.svelte";
    import F1RaceTrackDetail from "$lib/components/f1-race-track/f1-race-track-detail.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";

    let isLoading = $state(false);
    let loadingMessage = $state("");

    let raceTrackName = $state("");
    let countryId = $state(0);
    let opened = $state(0n);

    async function submitF1RaceTrack() {
        if (!raceTrackName) {
            alert("Please enter a race track name");
            return;
        }

        if (countryId === 0) {
            alert("Please select a country");
            return;
        }

        if (opened === 0n) {
            alert("Please select an opening year");
            return;
        }

        const dto: CreateRaceTrack = {
            name: raceTrackName,
            countryId,
            opened
        };

        try {
            isLoading = true;
            loadingMessage = "Creating F1 Race Track";
            await f1RaceTrackStore.addF1RaceTrack(dto);
            toasts.addToast({type: 'success', message: 'F1 Race Track created successfully!', duration: 5000});
            goto("/f1-race-tracks");
        } catch (error) {
            console.error("Failed to create F1 Race Track:", error);
            toasts.addToast({type: 'error', message: 'Failed to create F1 Race Track', duration: 5000});
        } finally {
            isLoading = false;
        }
    }
</script>

{#if isLoading}
    <LocalSpinner message={loadingMessage} />
{:else}
    <BrandPanel title="CREATE F1 RACE TRACK" subTitle="">
        <form onsubmit={submitF1RaceTrack} class="space-y-6 text-black">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <F1RaceTrackDetail 
                    bind:raceTrackName 
                    bind:countryId 
                    bind:opened
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