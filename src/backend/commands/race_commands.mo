import Types "../data-types/types";
module RaceCommands {
    public type CreateTournament = {
        name: Text;
    };

    public type CreateTournamentInstance = {
        raceId: Types.RaceId;
        year: Nat16;
        startDate: Int;
        endDate: Int;
    };

    public type AddTournamentResult = {
        raceId: Types.RaceId;
        year: Nat16;
        f1DriverId: Types.F1DriverId;
    };

    public type UpdateTournamentStage = {
        raceId: Types.RaceId;
        year: Nat16;
        stage: Types.RaceStage;
    };
}