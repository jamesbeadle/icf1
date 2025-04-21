
import Enums "mo:waterway-mops/Enums";
import Result "mo:base/Result";
import List "mo:base/List";
import Array "mo:base/Array";
import Order "mo:base/Order";
import Buffer "mo:base/Buffer";
import F1TeamQueries "../queries/f1_team_queries";
import F1TeamCommands "../commands/f1_team_commands";
import Types "../data-types/types";
import Environment "../environment";

module {
  public class F1TeamManager() {

    private var f1Teams: [Types.F1Team] = [];
    
    public func getF1Team(dto: F1TeamQueries.GetF1Team) : Result.Result<F1TeamQueries.F1Team, Enums.Error> {
      let f1Team = Array.find(f1Teams, func(entry: Types.F1Team) : Bool {
        entry.id == dto.f1TeamId
      });
      switch(f1Team){
        case (?foundF1Team){
          return #ok({
            f1TeamId = foundF1Team.id;
            countryId = foundF1Team.countryId;
            founded = foundF1Team.founded;
            name = foundF1Team.name;
          });
        };
        case (null){
          return #err(#NotFound); 
        }
      }
    };

    public func listF1Teams(dto: F1TeamQueries.ListF1Teams) : Result.Result<F1TeamQueries.F1Teams, Enums.Error> {
      let allEntries = List.fromArray(f1Teams);
      let startIndex = dto.page * Environment.PAGINATION_ROW_COUNT;
      let droppedEntries = List.drop<Types.F1Team>(allEntries, startIndex);
      let paginatedEntires = List.take<Types.F1Team>(droppedEntries, Environment.PAGINATION_ROW_COUNT);
      let mappedEntries = List.map<Types.F1Team, F1TeamQueries.F1TeamSummary>(paginatedEntires, func(entry: Types.F1Team){
        return {
          countryId = entry.countryId;
          founded = entry.founded;
          f1TeamId = entry.id;
          name = entry.name;
        };
      });

      return #ok({
        entries = List.toArray<F1TeamQueries.F1TeamSummary>(mappedEntries);
        page = dto.page;
        totalEntries = List.size(allEntries);
      });
    };

    public func createF1Team(dto: F1TeamCommands.CreateF1Team) : Result.Result<(), Enums.Error> {
      
      let sortedF1Teams = Array.sort(f1Teams, func(a: Types.F1Team, b: Types.F1Team) : Order.Order {
        if (a.id > b.id) { #less } 
        else if (a.id < b.id) { #greater }
        else { #equal }
      });

      var nextId: Nat16 = 1;

      if(Array.size(sortedF1Teams) > 0){
        nextId := sortedF1Teams[0].id + 1;
      };

      let f1TeamsBuffer = Buffer.fromArray<Types.F1Team>(f1Teams);
      f1TeamsBuffer.add({
        id = nextId;
        countryId = dto.countryId;
        founded = dto.founded;
        name = dto.name;
      });

      return #ok();
    };

    public func updateF1Team(dto: F1TeamCommands.UpdateF1Team) : Result.Result<(), Enums.Error> {
      let f1Team = Array.find(f1Teams, func(entry: Types.F1Team) : Bool {
        entry.id == dto.f1TeamId
      });
      switch(f1Team){
        case (?_){
          
          f1Teams := Array.map<Types.F1Team, Types.F1Team>(f1Teams, func(entry: Types.F1Team){
            if(entry.id == dto.f1TeamId){
              return {
                countryId = entry.countryId;
                founded = entry.founded;
                id = entry.id;
                name = dto.name;
              };
            };
            return entry;
          });
          return #ok();
        };
        case (null){
          return #err(#NotFound);
        }
      };
    };

    public func getStableF1Teams() : [Types.F1Team] {
      return f1Teams;
    };

    public func setStableF1Teams(stable_f1_teams: [Types.F1Team]) {
      f1Teams := stable_f1_teams;
    }


  };
};


    