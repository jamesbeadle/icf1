
import Types "../data-types/types";
import Ids "mo:waterway-mops/Ids";

module F1DriverQueries {
    
    public type GetF1Driver = {
        f1DriverId: Types.F1DriverId;
    };

    public type F1Driver = {
        f1DriverId: Types.F1DriverId;
        firstName: Text;
        lastName: Text;
        nationality: Ids.CountryId;
        f1TeamId: Types.F1TeamId;
    };

    public type ListF1Drivers = {
        page: Nat;
    };

    public type F1Drivers = {
        entries: [F1DriverSummary];
        totalEntries: Nat;
        page: Nat;
    };

    public type F1DriverSummary = {
        f1DriverId: Types.F1DriverId;
        firstName: Text;
        lastName: Text;
        nationality: Ids.CountryId;
        f1TeamId: Types.F1TeamId;
    };
    
}

  