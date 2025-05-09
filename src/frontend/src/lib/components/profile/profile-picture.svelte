<script lang="ts">
    import { onMount } from 'svelte';
    import { userStore } from '$lib/stores/user-store';
    import EditIcon from "$lib/icons/edit-icon.svelte";
    import UpdateProfilePictureModal from './modals/update-profile-picture-modal.svelte';
    import { getImageURL } from '$lib/utils/helpers';
    import LocalSpinner from '../shared/local-spinner.svelte';
    
    let isLoading = true;
    let profilePicture: string | null = null;
    let showUpdateProfilePicture = false;
    
    onMount(async () => {
        try {
            await userStore.sync();
            userStore.subscribe((user) => {
                if(!user){ return }
                let profilePictureResult = user.profilePicture;
                if(profilePictureResult[0]){
                    profilePicture = getImageURL(profilePictureResult[0]);
                }
                isLoading = false;
            });
        } catch (err) {
            console.error('Creating loading profile picture:', err);
        }
    });

</script>

{#if isLoading}
    <LocalSpinner />
{:else}

    <div class="relative flex items-center justify-center w-full aspect-[16/9] lg:aspect-square bg-yellow-400 rounded-lg">
        {#if profilePicture}
            <div class="relative w-full h-full">
                <img src={profilePicture} alt="Profile" class="object-cover w-full h-full rounded-lg"/>
                <button 
                    class="absolute p-2 transition-all duration-200 bg-black bg-opacity-50 rounded-full top-4 right-4 hover:bg-opacity-70"
                    on:click={() => showUpdateProfilePicture = true}
                    >
                    <EditIcon className="w-4 h-4" fill="white"/>
                </button>
            </div>                          
        {:else}
            <img src="default-profile-picture.jpg" alt="Default Profile" class="object-cover w-full h-full rounded-lg"/>
            <button 
                class="absolute transform -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2"
                on:click={() => showUpdateProfilePicture = true}
            >
                <EditIcon className="w-20 h-20" fill="white"/>
            </button>
        {/if}
    </div>

    {#if showUpdateProfilePicture}
        <UpdateProfilePictureModal
            showModal={showUpdateProfilePicture} 
            on:close={() => showUpdateProfilePicture = false} />
    {/if}
{/if}