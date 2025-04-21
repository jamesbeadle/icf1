import { ActorFactory } from "$lib/utils/actor.factory";
import { authStore } from "$lib/stores/auth-store";
import type {
  CreateUser,
  GetProfile,
  IsUsernameAvailable,
  Profile,
  UpdateProfilePicture,
  UpdateUsername,
  UsernameAvailable,
} from "../../../../declarations/backend/backend.did";
import { isError } from "$lib/utils/helpers";

export class UserService {

  async getProfile(dto: GetProfile): Promise<Profile> {
    const identityActor = await ActorFactory.createIdentityActor(
      authStore,
      process.env.BACKEND_CANISTER_ID ?? "",
    );

    const result: any = await identityActor.getProfile(dto);
    if (isError(result)) throw new Error("Failed to get profile");
    return result.ok;
  }

  async getBuzz(dto: GetBuzz): Promise<Buzz> {
    const identityActor = await ActorFactory.createIdentityActor(
      authStore,
      process.env.BACKEND_CANISTER_ID ?? "",
    );

    const result: any = await identityActor.getBuzzEntries(dto);
    if (isError(result)) throw new Error("Failed to get buzz entries");
    return result.ok;
  }

  async getUpcomingGames(dto: GetUpcomingGames): Promise<UpcomingGames> {
    const identityActor = await ActorFactory.createIdentityActor(
      authStore,
      process.env.BACKEND_CANISTER_ID ?? "",
    );

    const result: any = await identityActor.getUpcomingGames(dto);
    if (isError(result)) throw new Error("Failed to get upcoming games");
    return result.ok;
  }

  async isUsernameAvailable(
    dto: IsUsernameAvailable,
  ): Promise<UsernameAvailable> {
    return false; //TODO
  }

  async createUser(dto: CreateUser): Promise<any> {
    try {
      const identityActor = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );
      const result = await identityActor.createUser(dto);
      return result;
    } catch (error) {
      console.error("Error creating user:", error);
      throw error;
    }
  }

  async updateUsername(dto: UpdateUsername): Promise<any> {
    try {
      const identityActor = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );
      const result = await identityActor.updateUsername(dto);
      return result;
    } catch (error) {
      console.error("Error updating username:", error);
      throw error;
    }
  }

  async updateProfilePicture(dto: UpdateProfilePicture): Promise<any> {
    try {
      const identityActor = await ActorFactory.createIdentityActor(
        authStore,
        process.env.BACKEND_CANISTER_ID ?? "",
      );
      const result = await identityActor.updateProfilePicture(dto);
      return result;
    } catch (error) {
      console.error("Error updating profile picture:", error);
      throw error;
    }
  }
}
