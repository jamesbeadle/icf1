<script lang="ts">
    import { goto } from "$app/navigation";
    import ConfirmModal from "$lib/components/shared/confirm-modal.svelte";
    import { f1TeamStore } from "$lib/stores/f1-team-store";
    import type { CreateF1Team } from "../../../../../declarations/backend/backend.did";
    import Layout from "../../+layout.svelte";

    let teamName = "";
    let founded = 0n;
    let countryId = 0;
   

    function resetForm() {
        teamName = "";
    }

    async function submitF1Team() {
        if (!teamName) {
            alert("Please fill in the team name.");
            return;
        }


        const dto: CreateF1Team = {
            name: teamName,
            founded,
            countryId: countryId,
        };

        await f1TeamStore.addF1Team(dto);
        goto("/governance");
    }
</script>

<Layout>
    <div class="modal">
        <div class="modal-header">
            <h1>EDIT F1 TEAM DETAILS</h1>
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
</Layout>

