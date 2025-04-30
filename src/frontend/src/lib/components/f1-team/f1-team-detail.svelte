<script lang="ts">
    import type { CountryId } from "../../../../../declarations/backend/backend.did";
    import { countries } from "$lib/types/countries";

    interface Props {
        teamName: string;
        countryId: CountryId;
        founded: bigint;
    }

    let { teamName = $bindable(""), countryId = $bindable(0), founded = $bindable(0n) }: Props = $props();
</script>

<div class="space-y-4">
    <div>
        <label for="teamName" class="block text-sm font-medium text-gray-700">Team Name</label>
        <input
            id="teamName"
            type="text"
            bind:value={teamName}
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
        <label for="founded" class="block text-sm font-medium text-gray-700">Year Founded</label>
        <input
            id="founded"
            type="number"
            bind:value={founded}
            min="1900"
            max={new Date().getFullYear()}
            placeholder="YYYY"
            class="block w-full p-2 mt-1 border rounded-md shadow-sm border-BrandDivider focus:ring-BrandForest focus:border-BrandForest"
            required
        />
    </div>
</div>