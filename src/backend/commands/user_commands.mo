import Types "../data-types/types";

module UserCommands {
    public type CreateProfile = {
        username: Text;
        profilePicture: ?Blob;
    };

    public type UpdateProfilePicture = {
        profilePicture: ?Blob;
    };

    public type UpdateUsername = {
        username: Text;
    };

    public type SubmitPrediction = {
        raceId: Types.RaceId;
        year: Nat16;
    };
}

  