<script lang="ts">
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";
    import ConfirmModal from "$lib/components/shared/confirm-modal.svelte";
    import { f1TeamStore } from "$lib/stores/f1-team-store";
    import type { CreateF1Team, F1Team, UpdateF1Team } from "../../../../../../declarations/backend/backend.did";
    import { page } from "$app/state";
    import Layout from "../../../Layout.svelte";
    
    let f1TeamId: bigint = BigInt(page.params.id);
    let f1Team: F1Team | null = null;
    let loading = true;
    let error: string | null = null;

    let teamName = "";
    let founded = 0n;
    let countryId = 0;
    
    onMount(async () => {
        try {
            f1Team = await f1TeamStore.getF1Team({ id: f1TeamId });
            if (f1Team) {
                teamName = f1Team.name;
                founded = f1Team.founded;
                countryId = f1Team.countryId;
            }
        } catch (err) {
            error = err instanceof Error ? err.message : 'An unexpected error occurred';
        } finally {
            loading = false;
        }
    });

    function resetForm() {
        if (f1Team) {
            teamName = f1Team.name;
            founded = f1Team.founded;
            countryId = f1Team.countryId;
        }
    }

    async function submitF1Team() {
        if (!teamName) {
            alert("Please fill in the F1 team name.");
            return;
        }

        const dto: UpdateF1Team = {
            f1TeamId: BigInt(page.params.id),
            name: f1TeamName,
        };

        await f1TeamStore.updateF1Team(dto);
        goto("/governance");
    }
</script>

<Layout>
    {#if loading}
        <div class="loading">Loading F1 Team...</div>
    {:else if error}
        <div class="error">Error: {error}</div>
    {:else}
        <div class="modal">
            <div class="modal-header">
                <h1>EDIT F1 TEAM DETAILS</h1>
                <p>Update your F1 team details and submit a proposal for changes.</p>
                <button class="close-btn" on:click={() => goto("/governance")}>✕</button>
            </div>

            <div class="form-section">
                <label for="f1-team-name">F1 TEAM NAME</label>
                <input id="f1-team-name" type="text" bind:value={f1TeamName} placeholder="Enter F1 Team Name" />

                <div class="form-actions">
                    <button class="cancel-btn" on:click={resetForm}>RESET</button>
                    <button class="update-btn" on:click={submitF1Team}>UPDATE</button>
                </div>
            </div>
        </div>
    {/if}
</Layout>