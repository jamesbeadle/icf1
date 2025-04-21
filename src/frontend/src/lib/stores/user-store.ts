import { authStore } from "$lib/stores/auth-store";
import { getFileExtensionFromFile, isError } from "$lib/utils/helpers";
import { writable } from "svelte/store";
import { ActorFactory } from "$lib/utils/actor.factory";
import { UserService } from "$lib/services/user-service";
import type {
  GetProfile,
  IsUsernameAvailable,
  Profile,
  UpdateProfilePicture,
  UpdateUsername,
  UsernameAvailable,
} from "../../../../declarations/backend/backend.did";

function createUserStore() {
  const { subscribe, set } = writable<Profile | null>(null);

  //Syncing and caching of store data

  async function sync() {
    let localStorageString = localStorage.getItem("user_profile_data");
    if (localStorageString) {
      const localProfile = JSON.parse(localStorageString);
      set(localProfile);
      return;
    }
    try {
      await cacheProfile();
    } catch (error) {
      console.error("Error fetching user profile:", error);
      throw error;
    }
  }

  async function cacheProfile() {
    const identityActor: any = await ActorFactory.createIdentityActor(
      authStore,
      process.env.BACKEND_CANISTER_ID ?? "",
    );

    authStore.subscribe(async (user) => {
      let principalId = user.identity?.getPrincipal().toString();
      if (!principalId) {
        return;
      }

      let dto: GetProfile = {
        principalId,
      };

      let getProfileResponse = await identityActor.getProfile(dto);
      let error = isError(getProfileResponse);
      if (error) {
        console.error("Error fetching user profile");
        return;
      }
      let profileData = getProfileResponse.ok;
      set(profileData);
    });
  }

  //User Query Functions

  async function getProfile(principalId: string): Promise<Profile | null> {
    const identityActor: any = await ActorFactory.createIdentityActor(
      authStore,
      process.env.BACKEND_CANISTER_ID ?? "",
    );

    let dto: GetProfile = {
      principalId,
    };

    let getProfileResponse = await identityActor.getProfile(dto);
    let error = isError(getProfileResponse);
    if (error) {
      console.error("Error fetching user profile");
      return null;
    }
    return getProfileResponse.ok;
  }

  async function isUsernameAvailable(
    dto: IsUsernameAvailable,
  ): Promise<UsernameAvailable> {
    return new UserService().isUsernameAvailable(dto);
  }

  //User Commands Functions

  async function createUser(dto: CreateUser): Promise<any> {
    return new UserService().createUser(dto);
  }

  async function updateUsername(dto: UpdateUsername): Promise<any> {
    return new UserService().updateUsername(dto);
  }

  async function updateProfilePicture(
    principalId: string,
    picture: File,
  ): Promise<any> {
    try {
      const maxPictureSize = 1000;
      const extension = getFileExtensionFromFile(picture);

      if (picture.size > maxPictureSize * 1024) {
        return null;
      }
      const reader = new FileReader();
      reader.readAsArrayBuffer(picture);
      reader.onloadend = async () => {
        const arrayBuffer = reader.result as ArrayBuffer;
        const uint8Array = new Uint8Array(arrayBuffer);
        try {
          const identityActor = await ActorFactory.createIdentityActor(
            authStore,
            process.env.BACKEND_CANISTER_ID ?? "",
          );

          let dto: UpdateProfilePicture = {
            principalId: principalId,
            profilePicture: [uint8Array],
            profilePictureExtension: extension,
          };
          const result = await identityActor.updateUserPicture(dto);
          if (isError(result)) {
            console.error("Error updating profile picture");
            return;
          }

          await cacheProfile();
          return result;
        } catch (error) {
          console.error(error);
        }
      };
    } catch (error) {
      console.error("Error updating profile picture:", error);
      throw error;
    }
  }

  return {
    subscribe,
    sync,
    cacheProfile,
    getProfile,
    isUsernameAvailable,
    createUser,
    updateUsername,
    updateProfilePicture,
  };
}

export const userStore = createUserStore();
