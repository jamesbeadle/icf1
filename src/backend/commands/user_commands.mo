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
        teamSelections: [TeamSelection];
    };

    public type TeamSelection = {
        f1TeamId: Types.F1TeamId;
        fastestTeamSelectionIndex: Nat8;
        leadDriver: Types.F1DriverId;
        secondDriver: Types.F1DriverId;
        leadDriverBonuses: [Types.BonusType];
        secondDriverBonuses: [Types.BonusType];
    };
}

  