import Types "../data-types/types";
import Ids "mo:waterway-mops/Ids";
module RaceQueries {
    
    public type GetRaceTrack = {
        raceTrackId: Types.RaceTrackId;
    };

    public type RaceTrack = {
        raceTrackId: Types.RaceTrackId;
        name: Text;
        country: Ids.CountryId;
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

  