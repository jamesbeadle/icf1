import Types "../data-types/types";
module RaceQueries {
    
    public type GetRaceTrack = {
        raceTrackId: Types.RaceTrackId;
    };

    public type RaceTrack = {
        raceTrackId: Types.RaceTrackId;

    };

    public type ListRaceTracks = {
        page: Nat;
    };

    public type RaceTracks = {
        entries: [RaceTrackSummary];
        totalEntries: Nat;
        page: Nat;
    };

    public type RaceTrackSummary = {
        raceId: Types.RaceId;
        name: Text;
    };
    
}

  