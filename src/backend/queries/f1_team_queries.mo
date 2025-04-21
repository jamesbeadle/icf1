import Types "../data-types/types";
import Ids "mo:waterway-mops/Ids";
module F1TeamQueries {
    
    public type GetF1Team = {
        f1TeamId: Types.F1TeamId;
    };

    public type F1Team = {
        f1TeamId: Types.F1TeamId;
        name: Text;
        founded: Int;
        countryId: Ids.CountryId;
    };

    public type ListF1Teams = {
        page: Nat;
    };

    public type F1Teams = {
        entries: [F1TeamSummary];
        totalEntries: Nat;
        page: Nat;
    };

    public type F1TeamSummary = {
        f1TeamId: Types.F1TeamId;
        name: Text;
        founded: Int;
        countryId: Ids.CountryId;
    };
    
}

  