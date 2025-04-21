import Types "../data-types/types";
module RaceQueries {
    
    public type GetRace = {
        raceId: Types.RaceId;
    };

    public type Race = {
        raceId: Types.RaceId;


    };
    
    public type GetRaceInstance = {
        raceId: Types.RaceId;
        year: Nat16;
    };

    public type RaceInstance = {
        raceId: Types.RaceId;
        year: Nat16;
        populated: Bool;
        raceTrackId: Types.RaceTrackId;
        startDate: Int;
        endDate: Int;
        leaderboard: TournamentLeaderboard;
        stage: Types.TournamentStage;
    };

    public type TournamentLeaderboard = {
        totalEntries: Nat;
        entries: [TournamentLeaderboardEntry];
    };

    public type RaceLeaderboardEntry = {
        f1DriverId: Types.DriverId;
        raceId: Types.RaceId;
        laps: [Types.F1RaceLap];
        raceTime: Nat;
    };

    public type ListRaces = {
        page: Nat;
    };

    public type Races = {
        entries: [RaceSummary];
        totalEntries: Nat;
        page: Nat;
    };

    public type RaceSummary = {
        raceId: Types.RaceId;
        name: Text;
    };
    
}

  