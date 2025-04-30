<script lang="ts">
    import { goto } from "$app/navigation";
    import { f1DriverStore } from "$lib/stores/f1-driver-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { CreateF1Driver, CountryId, F1Team } from "../../../../../../../declarations/backend/backend.did";

    import BrandPanel from "$lib/components/shared/brand-panel.svelte";
    import DriverDetail from "$lib/components/f1-driver/driver-detail.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";

    let isLoading = $state(false);
    let loadingMessage = $state("");

    let f1TeamId = $state(0);
    let firstName = $state("");
    let lastName = $state("");
    let nationality = $state(0);

    let f1Team = $state<F1Team | null>(null);
    

    async function submitF1Driver() {
        if (!firstName || !lastName) {
            alert("Please enter both first and last name");
            return;
        }

        if (nationality === 0) {
            alert("Please select a nationality");
            return;
        }

        const dto: CreateF1Driver = {
            firstName,
            lastName,
            nationality,
            f1TeamId
        };

        try {
            isLoading = true;
            loadingMessage = "Creating F1 Driver";
            await f1DriverStore.addF1Driver(dto);
            toasts.addToast({type: 'success', message: 'F1 Driver created successfully!', duration: 5000});
            goto("/f1-drivers");
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
            <DriverDetail 
                bind:firstName 
                bind:lastName 
                bind:nationality
                bind:f1TeamId
            />
        </div>

        <div class="flex justify-end pt-6">
            <button
                type="button"
                class="px-4 py-2 mr-3 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-BrandForest"
                onclick={() => goto("/f1-drivers")}
            >
                Cancel
            </button>
            <button
                type="submit"
                class="inline-flex justify-center px-4 py-2 text-sm font-medium text-white border border-transparent rounded-md shadow-sm bg-BrandForest hover:bg-BrandForest/80 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-BrandForest"
            >
                Create Driver
            </button>
        </div>
        </form>
    </BrandPanel>
{/if}