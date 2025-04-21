<script lang="ts">

    import { onMount } from 'svelte';
    import { userStore } from "$lib/stores/user-store";
    import type { Profile } from "../../../../../declarations/backend/backend.did";
    
    import UpdateUsernameModal from './modals/update-username-modal.svelte';
    import EditIcon from "$lib/icons/edit-icon.svelte";
    import BrandPanel from '../shared/brand-panel.svelte';
    import LocalSpinner from '../shared/local-spinner.svelte';
    import { toasts } from '$lib/stores/toasts-store';

    let isLoading = true;
    let profile: Profile;
    let showUpdateUsernameModal = false;
    
    onMount(async () => {
        try {
            await userStore.sync();
            userStore.subscribe((user) => {
                if(!user){ return }
                profile = user;
                isLoading = false;
            });
        } catch (err) {
            console.error('Creating loading profile detail:', err);
        }
    });
</script>

{#if isLoading}
    <LocalSpinner />
{:else}
    <BrandPanel title="DETAILS" subTitle="TELL US ABOUT YOURSELF">
        <div class="relative w-full p-4">
            <div class="text-BrandGray text-sm">USERNAME</div>
            <div class="text-4xl condensed">{profile.username}</div>
            <button on:click={() => showUpdateUsernameModal = true } class="absolute top-4 right-4">
                <EditIcon className="w-4" />
            </button>
        </div>
    </BrandPanel>

    {#if showUpdateUsernameModal}
        <UpdateUsernameModal />
    {/if}

{/if}