
import Ids "mo:waterway-mops/Ids";
import Types "../data-types/types";

module RaceTrackCommands {
    public type CreateRaceTrack = {
        name: Text;
        countryId: Ids.CountryId;
        opened: Int;
    };

    public type UpdateRaceTrack = {
        raceTrackId: Types.RaceTrackId;
        name: Text;
        countryId: Ids.CountryId;
        opened: Int;
        closed: ?Int;
    };
}