import Types "../data-types/types";
import Ids "mo:waterway-mops/Ids";
module F1TeamCommands {
    public type CreateF1Team = {
        name: Text;
        countryId: Ids.CountryId;
        founded: Int;
    };

    public type F1Team = {
        name: Text;
        countryId: Ids.CountryId;
        founded: Int;
    };

    public type UpdateF1Team = {
        f1TeamId: Types.F1TeamId;
        name: Text;
    };
}