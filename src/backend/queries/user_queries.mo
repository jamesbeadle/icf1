import Ids "mo:waterway-mops/Ids";
import Types "../data-types/types";
module UserQueries {

    public type GetProfile = {};

    public type Profile = {
        principalId: Ids.PrincipalId;
        username: Text;
        joinedOn: Int;
    };

    public type GetPrediction = {
        raceId: Types.RaceId;
        year: Nat16;
    };

    public type Prediction = {
        principalId: Ids.PrincipalId;
        username: Text;
        raceId: Types.RaceId;
        year: Nat16;
    };

    public type ListPredictions = {
        page: Nat;
    };

    public type Predictions = {
        entries: [PredictionSummary];
        totalEntries: Nat;
        page: Nat;
    };

    public type PredictionSummary = {
        principalId: Ids.PrincipalId;
        raceId: Types.RaceId;
        year: Nat16;
        points: Int8;
        createdOn: Int;
    };

    public type GetRaceCard = {
        principalId: Ids.PrincipalId;
        raceId: Types.RaceId;
        year: Nat16;
    };
    
    public type IsUsernameValid = {
        username : Text;
    };
}

  