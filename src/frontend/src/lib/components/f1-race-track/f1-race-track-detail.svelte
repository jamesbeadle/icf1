<script lang="ts">
    import type { CountryId } from "../../../../../declarations/backend/backend.did";
    import { countries } from "$lib/types/countries";

    interface Props {
        raceTrackName: string;
        countryId: CountryId;
        opened: bigint;
    }

    let { raceTrackName = $bindable(""), countryId = $bindable(0), opened = $bindable(0n) }: Props = $props();
</script>

<div class="space-y-4">
    <div>
        <label for="raceTrackName" class="block text-sm font-medium text-gray-700">First Name</label>
        <input
            id="raceTrackName"
            type="text"
            bind:value={raceTrackName}
            class="block w-full p-2 mt-1 border rounded-md shadow-sm border-BrandDivider focus:ring-BrandForest focus:border-BrandForest"
            required
        />
    </div>

    <div>
        <label for="countryId" class="block text-sm font-medium text-gray-700">Country</label>
        <select
            id="countryId"
            bind:value={countryId}
            class="block w-full p-2 mt-1 border rounded-md shadow-sm border-BrandDivider focus:ring-BrandForest focus:border-BrandForest"
            required
        >
            <option value="0">Select nationality</option>
            {#each countries as country}
                <option value={country.id}>{country.countryName}</option>
            {/each}
        </select>
    </div>

    <div>
        <label for="opened" class="block text-sm font-medium text-gray-700">Year Opened</label>
        <input
            id="opened"
            type="number"
            bind:value={opened}
            min="1900"
            max={new Date().getFullYear()}
            placeholder="YYYY"
            class="block w-full p-2 mt-1 border rounded-md shadow-sm border-BrandDivider focus:ring-BrandForest focus:border-BrandForest"
            required
        />
    </div>
</div>