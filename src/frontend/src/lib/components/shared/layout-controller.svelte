<script lang="ts">
    import { authSignedInStore } from '$lib/derived/auth.derived';
    import { userIdCreatedStore } from '$lib/stores/user-control-store';
    import {type Snippet } from 'svelte';
    import { page } from '$app/state';

    import Navigation from '$lib/components/shared/navigation.svelte';
    import Header from '$lib/components/shared/header.svelte';
    import FullScreenSpinner from '$lib/components/shared/full-screen-spinner.svelte';
    import NewUser from '$lib/components/profile/new-user.svelte';
    import Landing from '$lib/components/landing/landing.svelte';

    interface Props {
        children: Snippet;
    }
    let { children }: Props = $props();
    let isMenuOpen = $state(false);
    let isLoading = $state(false);

    function toggleNav() {
        isMenuOpen = !isMenuOpen;
    }
</script>

{#if isLoading}
    <FullScreenSpinner message="Loading..." />
{:else if $authSignedInStore}
<div class="bg-white">
    <Navigation expanded={isMenuOpen} {toggleNav}/>
    <Header {toggleNav} />
    {#if $userIdCreatedStore?.data}
        {@render children()}
     {:else}
        <NewUser />
    {/if}
    </div>
{:else}
    <Navigation expanded={isMenuOpen} {toggleNav}/>
    <Header {toggleNav} />
    {#if page.route.id === '/'}
        <Landing />
    {:else}
        <div class="flex flex-col min-h-screen bg-background">
            <main class="flex-grow page-wrapper">
                {@render children()}
            </main>
        </div>
    {/if}
{/if}
