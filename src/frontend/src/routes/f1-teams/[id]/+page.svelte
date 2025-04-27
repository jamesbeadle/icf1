<script lang="ts">
    import Layout from "../../+layout.svelte";
    import type { F1Team } from "../../../../../declarations/backend/backend.did";
    import { onMount } from "svelte";
    import { f1TeamStore } from "$lib/stores/f1-team-store";
    import { getImageURL } from "$lib/utils/helpers";
    import { page } from "$app/state";
    
    let f1Team: F1Team | null = null;
    let loading = true;
    let error: string | null = null;

    onMount(async () => {
        try {
            f1Team = await f1TeamStore.getF1Team({ id: BigInt(page.params.id) });
        } catch (err) {
            error = err instanceof Error ? err.message : 'An unexpected error occurred';
        } finally {
            loading = false;
        }
    });
</script>

<Layout>
    {#if loading}
        <div class="loading">Loading F1 Team...</div>
    {:else if error}
        <div class="error">Error: {error}</div>
    {:else if f1Team}
        <div class="f1-team-container">
            <div class="f1-team-header">
                <h1>{f1Team.name}</h1>
            </div>

            <div class="f1-team-details">
                <div class="detail-grid">
                    <div class="detail-item">
                        <span class="label">Founded:</span>
                        <span class="value">{f1Team.founded}</span>
                    </div>
                    <div class="detail-item">
                        <span class="label">Country ID:</span>
                        <span class="value">{f1Team.countryId}</span>
                    </div>
                </div>
            </div>
        </div>
    {:else}
        <div class="not-found">F1 Team not found</div>
    {/if}
</Layout>