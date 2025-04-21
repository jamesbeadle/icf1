import Ids "mo:waterway-mops/Ids";

module Types {

    public type F1DriverId = Nat16;
    public type F1TeamId = Nat16;
    public type RaceId = Nat16;
    public type PredictionId = Nat16;

    public type Profile = {
        principalId: Ids.PrincipalId;
        username: Text;
        joinedOn: Int;
        profilePicture : ?Blob;
    };

    public type Prediction = {
        principalId: Ids.PrincipalId;
        createdOn: Int;
        username: Text;
        raceId: RaceId;
        year: Nat16;

        
    };

    public type F1Driver = {
        id: F1DriverId;
        firstName: Text;
        lastName: Text;
        nationality: Ids.CountryId;
        f1TeamId: F1TeamId;
    };  

    public type F1Team = {
        id: F1TeamId;
        name: Text;
        founded : Int;
        countryId : Ids.CountryId;
    };

    public type Race = {
        id: RaceId;
        name: Text;
        instances: [RaceInstance];
    };

    public type RaceInstance = {
        raceId: RaceId;
        year: Nat16;
        startDate: Int;
        endDate: Int;
        leaderboard: RaceLeaderboard;
        stage: RaceStage;
        populated: Bool;
    };

    public type RaceLeaderboard = {
        totalEntries: Nat;
        entries: [RaceLeaderboardEntry];
    };

    public type RaceLeaderboardEntry = {
        f1DriverId: F1DriverId;
        raceId: RaceId;
        raceTime: Nat;
    };

    public type RaceStage = {
        #NotStarted;
        #Completed;
    };

    public type FantasyLeaderboard = {
        raceId: RaceId;
        year: Nat16;
        entries: [FantasyLeaderboardEntry];
        totalEntries : Nat;
    };

    public type FantasyLeaderboardEntry = {
        principalId: Ids.PrincipalId;
        username: Text;
        points: Int8;
        position : Nat;
        positionText : Text;
    };

}