<script lang="ts">
    import { onMount } from "svelte";
    import Layout from "../../+layout.svelte";
    import { page } from "$app/state";
    import { f1DriverStore } from "$lib/stores/f1-driver-store";
    import type { F1Driver, GetF1Driver } from "../../../../../../../declarations/backend/backend.did";
    import LocalSpinner from "$lib/components/shared/local-spinner.svelte";
    import { getImageURL } from "$lib/utils/helpers";

    let isLoading = true;
    let f1DriverId: number;
    let f1Driver: F1Driver | null = null;

    onMount(async () => {
        f1DriverId = Number(page.params.id);
        let dto: GetF1Driver = { f1DriverId: f1DriverId };
        f1Driver = await f1DriverStore.getF1Driver(dto);
        isLoading = false;
    });

</script>

<Layout>
    {#if isLoading}
        <LocalSpinner />
    {:else}
        <div class="flex flex-row">
            <div class="flex flex-col w-1/2">
                <p>NAME</p>
                <p>{f1Driver?.firstName} {f1Driver?.lastName}</p>
            </div>
        </div>
    {/if}
</Layout>