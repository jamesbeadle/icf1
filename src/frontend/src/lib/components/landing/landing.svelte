<script lang="ts">

    import { authStore, type AuthSignInParams } from "$lib/stores/auth-store";

    function handleLogin() {
        let params: AuthSignInParams = {
            domain: import.meta.env.VITE_AUTH_PROVIDER_URL,
        };
        authStore.signIn(params);
    }

</script>


<div class="z-10 px-4 mb-20 text-center">
    <h1 class="mb-1 font-bold text-BrandForest">WELCOME TO <span class="condensed">ICF1</span></h1>
    <h2 class="mx-16 mb-6 text-5xl font-black leading-tight text-black md:text-6xl condensed">F1 MEETS WEB3</h2>
    
    <button 
        class="brand-button"
        on:click={handleLogin}
    >
        CONNECT
    </button>
    
</div>