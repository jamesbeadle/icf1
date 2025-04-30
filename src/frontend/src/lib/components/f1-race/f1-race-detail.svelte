<script lang="ts">
    interface Props {
        raceName: string;
    }

    let { raceName = $bindable("") }: Props = $props();
</script>

<div class="space-y-4">
    <div>
        <label for="raceTrackName" class="block text-sm font-medium text-gray-700">First Name</label>
        <input
            id="raceName"
            type="text"
            bind:value={raceName}
            class="block w-full p-2 mt-1 border rounded-md shadow-sm border-BrandDivider focus:ring-BrandForest focus:border-BrandForest"
            required
        />
    </div>
</div>