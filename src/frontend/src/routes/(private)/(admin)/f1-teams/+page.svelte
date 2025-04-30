<script lang="ts">
    import { onMount } from "svelte";
    import { goto } from "$app/navigation";
    import { authStore } from "$lib/stores/auth-store";
    import { f1TeamStore } from "$lib/stores/f1-team-store";
    import { toasts } from "$lib/stores/toasts-store";
    import type { F1Teams, ListF1Teams } from "../../../../../../declarations/backend/backend.did";
    
    import F1TeamSummaryRow from "$lib/components/f1-team/f1-team-summary-row.svelte";
    import ListViewPanel from "$lib/components/shared/list-view-panel.svelte";
    import PaginationRow from "$lib/components/shared/pagination-row.svelte";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";

    let isLoading = true;
    let f1Teams: F1Teams | null = null;
    let page = 1n; 
    let pageSize = 10n; 

    onMount( async () => {
        loadF1Teams();
    });

    function createNew(){
        goto('/f1-teams/create')
    }

    async function changePage(newPage: bigint) {
        if (!f1Teams) return;

        const totalPages = f1Teams.totalEntries / pageSize + (f1Teams.totalEntries % pageSize > 0n ? 1n : 0n);
        if (newPage < 1n || newPage > totalPages) {
            return;
        }
        page = newPage;
        await loadF1Teams();
    }

    async function loadF1Teams() {
        isLoading = true;
        try {
            const store = $authStore;
            const principalId = store.identity?.getPrincipal();

            if (!principalId) {
                goto('/');
                return;
            }

            let dto: ListF1Teams = { page: page };

            f1Teams = await f1TeamStore.getF1Teams(dto);
        } catch {
            toasts.addToast({type: 'error', message: 'Error loading F1 teams.'});
            f1Teams = null;
        } finally {
            isLoading = false;
        }
    }

</script>

{#if isLoading}
    <LocalSpinner />
{:else}
    <ListViewPanel title="F1 Team" buttonTitle="ADD F1 Team" buttonCallback={createNew}>
        {#if f1Teams}

            {#if f1Teams.entries.length > 0}
                {#each f1Teams?.entries! as f1Team}
                    <F1TeamSummaryRow {f1Team} />
                {/each}
            {:else}
                <p>No F1 teams found.</p>
            {/if}                

            <PaginationRow {changePage} {page} {pageSize} total={f1Teams.totalEntries} typeName='f1Teams' />
        {:else}
            <p>Error loading F1 teams.</p>
        {/if}
    </ListViewPanel>
{/if}