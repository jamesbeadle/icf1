
import Ids "mo:waterway-mops/Ids";
import Types "../data-types/types";

module F1DriverCommands {
    public type CreateF1Driver = {
        firstName: Text;
        lastName: Text;
        nationality: Ids.CountryId;
        f1TeamId: Types.F1TeamId;
    };

    public type UpdateF1Driver = {
        f1DriverId: Types.F1DriverId;
        firstName: Text;
        lastName: Text;
        nationality: Ids.CountryId;
        f1TeamId: Types.F1TeamId;
    };
}