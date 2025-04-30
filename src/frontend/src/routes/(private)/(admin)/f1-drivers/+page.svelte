<script lang="ts">
    import { onMount } from "svelte";
    import { goto } from "$app/navigation";
    import { authStore } from "$lib/stores/auth-store";
    import { f1DriverStore } from "$lib/stores/f1-driver-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { F1Drivers, ListF1Drivers } from "../../../../../../declarations/backend/backend.did";
    
    import ListViewPanel from "$lib/components/shared/list-view-panel.svelte";
    import PaginationRow from "$lib/components/shared/pagination-row.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";
    import DriversSummaryRow from "$lib/components/f1-driver/drivers-summary-row.svelte";

    let isLoading = $state(true);
    let f1Drivers: F1Drivers | null = $state(null);
    let page = $state(1n);
    let totalPages = $state(1n); 

    onMount( async () => {
        await loadF1Drivers(page);
    });

    async function changePage(delta: bigint) {
        const newPage = page + delta;
        if (newPage >= 1 && newPage <= Number(totalPages)) {
            page = BigInt(newPage);
            await loadF1Drivers(page);
        }
    }

    async function loadF1Drivers(page: bigint) {
        isLoading = true;
        try {

            let dto: ListF1Drivers = {page: page};

            f1Drivers = await f1DriverStore.getF1Drivers(dto);
            
            sortF1Drivers();
        } catch {
            toasts.addToast({type: 'error', message: 'Error loading F1 drivers.'});
            f1Drivers = null;
        } finally {
            isLoading = false;
        }
    }

    async function sortF1Drivers() {
        if (f1Drivers) {
            f1Drivers.entries.sort((a, b) => Number(a.f1DriverId) - Number(b.f1DriverId));
        }
    }

    function createNew() {
        goto('/f1-drivers/create');
    }

</script>

{#if isLoading}
    <LocalSpinner />
{:else}
    <ListViewPanel title="F1 Drivers" buttonTitle="ADD DRIVER" buttonCallback={createNew}>
        {#if f1Drivers}
            {#if f1Drivers.entries.length > 0}
                {#each f1Drivers?.entries! as f1Driver}
                    <DriversSummaryRow {f1Driver} />
                {/each}
                <PaginationRow {changePage} {page} total={f1Drivers.totalEntries} typeName='f1Drivers' pageSize={f1Drivers.page} />
            {:else}
                <p>No F1 Drivers found.</p>
            {/if}                
        {:else}
            <p>Error loading F1 drivers.</p>
        {/if}
    </ListViewPanel>
{/if}