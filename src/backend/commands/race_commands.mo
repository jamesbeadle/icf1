import Types "../data-types/types";
module RaceCommands {
    public type CreateRace = {
        name: Text;
    };

    public type CreateRaceInstance = {
        raceId: Types.RaceId;
        year: Nat16;
        startDate: Int;
        endDate: Int;
    };

    public type AddRacetResult = {
        raceId: Types.RaceId;
        year: Nat16;
        f1DriverId: Types.F1DriverId;
    };

    public type UpdatRaceStage = {
        raceId: Types.RaceId;
        year: Nat16;
        stage: Types.RaceStage;
    };
}