import Types "../data-types/types";
module FantasyLeaderboardCommands {

    public type CalculateLeaderboard = {
        raceId: Types.RaceId;
        year: Nat16;
    };
}