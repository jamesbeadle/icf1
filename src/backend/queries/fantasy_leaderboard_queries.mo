import Types "../data-types/types";
import Ids "mo:waterway-mops/Ids";

module FantasyLeaderboardQueries {

    public type GetFantasyLeaderboard = {
        raceId: Types.RaceId;
        page: Nat;
    };

    public type FantasyLeaderboard = {
        raceId: Types.RaceId;
        entries: [FantasyLeaderboardEntry];
        totalEntries: Nat;
        page: Nat;
    };

    public type FantasyLeaderboardEntry = {
        principalId: Ids.PrincipalId;
        username: Text;
        points: Int8;
    };

}

  