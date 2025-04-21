<script lang="ts">
    import type { ProfileSummary } from "../../../../../declarations/backend/backend.did";
    import { getImageURL } from "$lib/utils/helpers";

    export let profile: ProfileSummary;
</script>

<div class="flex flex-row items-center gap-3">
    <div class="relative">
        <img 
            src={getImageURL(plaprofileyer.profilePicture)} 
            alt={profile.name}
            class="w-10 h-10 rounded-full bg-BrandYellow"
        />
    </div>
    <p class="text-lg text-black condensed">
        {profile.name}
    </p>
</div>