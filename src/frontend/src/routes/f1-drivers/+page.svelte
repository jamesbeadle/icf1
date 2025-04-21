<script lang="ts">
    import { onMount } from "svelte";
    import { goto } from "$app/navigation";
    import { authStore } from "$lib/stores/auth-store";
    import { f1DriverStore } from "$lib/stores/f1-driver-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { F1Teams, GetF1Teams } from "../../../../declarations/backend/backend.did";
    
    import Layout from "../Layout.svelte";
    import BrandPanel from "$lib/components/shared/brand-panel.svelte";
    import PaginationRow from "$lib/components/shared/pagination-row.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";
    import F1TeamsSummaryRow from "$lib/components/f1-teams/f1-teams-summary-row.svelte";

    let isLoading = true;
    let f1Drivers: Drivers | null = null;
    let page = 1n;
    let totalPages = 1n; 
    let searchTerm = "";

    onMount( async () => {
        loadDrivers();
    });

    async function handleSearch() {
        page = 1n;
        await loadDrivers();
    }

    async function changePage(delta: bigint) {
        const newPage = page + delta;
        if (newPage >= 1 && newPage <= Number(totalPages)) {
            page = BigInt(newPage);
            await loadDrivers();
        }
    }

    async function loadF1Drivers() {
        isLoading = true;
        try {
            const store = $authStore;
            const principalId = store.identity?.getPrincipal();

            if (!principalId) {
                goto('/');
                return;
            }

            let dto: GetF1Drivers = {};

            f1Drivers = await f1DriverStore.getF1Drivers(dto);
            
            if (f1Drivers?.total && f1Drivers?.pageSize) {
                totalPages = BigInt(Math.ceil(Number(f1Drivers.total) / Number(f1Drivers.pageSize)));
            }
        } catch {
            toasts.addToast({type: 'error', message: 'Error loading F1 drivers.'});
            f1Drivers = null;
        } finally {
            isLoading = false;
        }
    }

</script>
<Layout>
    {#if isLoading}
        <LocalSpinner />
    {:else}
        <BrandPanel title="F1 Drivers" subTitle="FIND DRIVERS">
            {#if f1Drivers}
                {#if f1Drivers.entries.length > 0}
                    {#each f1Drivers?.entries! as f1Driver}
                        <F1DriversSummaryRow {f1Driver} />
                    {/each}
                    <PaginationRow {changePage} {page} total={f1Drivers.total} typeName='f1Drivers' pageSize={f1Drivers.pageSize} />
                {:else}
                    <p>No F1 Drivers found.</p>
                {/if}                
            {:else}
                <p>Error loading F1 drivers.</p>
            {/if}
        </BrandPanel>
    {/if}
</Layout>