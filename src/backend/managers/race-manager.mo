import Types "../data-types/types";
import RaceCommands "../commands/race_commands";
import RaceQueries "../queries/race_queries";
import Result "mo:base/Result";
import Array "mo:base/Array";
import List "mo:base/List";
import Buffer "mo:base/Buffer";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Enums "mo:waterway-mops/Enums";
import Environment "../environment";


module {
  public class RaceManager() {

    private var races: [Types.Race] = [];

    public func getRace(dto: RaceQueries.GetRace) : Result.Result<RaceQueries.Race, Enums.Error> {
      let race = Array.find(races, func(entry: Types.Race) : Bool {
        entry.id == dto.raceId
      });
      switch(race){
        case (?foundRace){
          return #ok({
            raceId = foundRace.id;
          });
        };
        case (null){
          return #err(#NotFound); 
        }
      }
    };

    public func getRaceInstance(dto: RaceQueries.GetRaceInstance) : Result.Result<RaceQueries.RaceInstance, Enums.Error> {
      let race = Array.find(races, func(entry: Types.Race) : Bool {
        entry.id == dto.raceId
      });
      switch(race){
        case (?foundRace){
          
          let instance = Array.find<Types.RaceInstance>(foundRace.instances, func(entry: Types.RaceInstance) : Bool {
            return entry.year == dto.year;
          });
          switch(instance){
            case (?foundInstance){
              return #ok(
                {
                  raceId = dto.raceId; 
                  year = foundInstance.year; 
                  populated = foundInstance.populated; 
                  raceTrackId = foundInstance.raceTrackId;
                  startDate = foundInstance.startDate;
                  endDate = foundInstance.endDate;
                  leaderboard = foundInstance.leaderboard;
                  stage = foundInstance.stage;
                });
            };
            case (null){
              return #err(#NotFound);
            }
          }
        };
        case (null){
          return #err(#NotFound); 
        }
      }
    };
    
    public func listRaces(dto: RaceQueries.ListRaces) : Result.Result<RaceQueries.Races, Enums.Error> {
      
      let allEntries = List.fromArray(races);
      let startIndex = dto.page * Environment.PAGINATION_ROW_COUNT;
      let droppedEntries = List.drop<Types.Race>(allEntries, startIndex);
      let paginatedEntires = List.take<Types.Race>(droppedEntries, Environment.PAGINATION_ROW_COUNT);
      let mappedEntries = List.map<Types.Race, RaceQueries.RaceSummary>(paginatedEntires, func(entry: Types.Race){
        return {
          name = entry.name;
          raceId = entry.id;
        }
      });

      return #ok({
        entries = List.toArray<RaceQueries.RaceSummary>(mappedEntries);
        page = dto.page;
        totalEntries = List.size(allEntries);
      });
    };

    public func createRace(dto: RaceCommands.CreateRace) : Result.Result<(), Enums.Error> {

      let sortedRaces = Array.sort(races, func(a: Types.Race, b: Types.Race) : Order.Order {
        if (a.id > b.id) { #less } 
        else if (a.id < b.id) { #greater }
        else { #equal }
      });

      var nextId: Nat16 = 1;

      if(Array.size(sortedRaces) > 0){
        nextId := sortedRaces[0].id + 1;
      };

      let racesBuffer = Buffer.fromArray<Types.Race>(races);
      racesBuffer.add({
        id = nextId;
        name = dto.name;
        instances = [];
      });

      return #ok();
    };

    public func createRaceInstance(dto: RaceCommands.CreateRaceInstance) : Result.Result<(), Enums.Error> {
      
      let race = Array.find(races, func(entry: Types.Race) : Bool {
        entry.id == dto.raceId
      });
      switch(race){
        case (?foundRace){
          
          let existingInstance = Array.find<Types.RaceInstance>(foundRace.instances, func(entry: Types.RaceInstance) : Bool {
            entry.year == dto.year;
          });

          switch(existingInstance){
            case (?_){
              return #err(#AlreadyExists);
            };
            case (null){
              let instancesBuffer = Buffer.fromArray<Types.RaceInstance>(foundRace.instances);
              instancesBuffer.add({
                raceId = dto.raceId;
                raceTrackId = dto.raceTrackId;
                startDate = dto.startDate;
                endDate = dto.endDate;
                leaderboard = {
                  entries = [];
                  totalEntries = 0;
                };
                populated = false;
                stage = #NotStarted;
                year = dto.year;
              });
              //set the race instance

              return #ok();
            }
          }
        };
        case (null){
          return #err(#NotFound); 
        }
      };
    };

    public func updateRaceStage(dto: RaceCommands.UpdateRaceStage) : Result.Result<(), Enums.Error> {
      let race = Array.find(races, func(entry: Types.Race) : Bool {
        entry.id == dto.raceId
      });
      switch(race){
        case (?_){
          
          races := Array.map<Types.Race, Types.Race>(races, func(entry: Types.Race){
            if(entry.id == dto.raceId){
              return {
                id = entry.id;
                name = entry.name;
                instances = Array.map<Types.RaceInstance, Types.RaceInstance>(entry.instances, func(instanceEntry: Types.RaceInstance){
                  if(instanceEntry.year == dto.year){
                  
                    return {
                      raceId = instanceEntry.raceId;
                      raceTrackId = instanceEntry.raceTrackId;
                      endDate = instanceEntry.endDate;
                      leaderboard = instanceEntry.leaderboard;
                      stage = dto.stage;
                      startDate = instanceEntry.startDate;
                      year = instanceEntry.year;
                      populated = instanceEntry.populated;
                    }
                    
                  };
                  return instanceEntry;
                });
              }

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

    public func setPopulated(raceId: Types.RaceId, year: Nat16) {
      let race = Array.find(races, func(entry: Types.Race) : Bool {
        entry.id == raceId
      });
      switch(race){
        case (?_){
          
          races := Array.map<Types.Race, Types.Race>(races, func(entry: Types.Race){
            if(entry.id == raceId){
              return {
                id = entry.id;
                name = entry.name;
                instances = Array.map<Types.RaceInstance, Types.RaceInstance>(entry.instances, func(instanceEntry: Types.RaceInstance){
                  if(instanceEntry.year == year){
                  
                    return {
                      raceId = instanceEntry.raceId;
                      raceTrackId = instanceEntry.raceTrackId;
                      endDate = instanceEntry.endDate;
                      leaderboard = instanceEntry.leaderboard;
                      stage = instanceEntry.stage;
                      startDate = instanceEntry.startDate;
                      year = instanceEntry.year;
                      populated = true;
                    }
                    
                  };
                  return instanceEntry;
                });
              }

            };
            return entry;
          });
        };
        case (null){};
      }
    };

    public func getStableRaces() : [Types.Race] {
      return races;
    };

    public func setStableRaces(stable_races : [Types.Race]) {
      races := stable_races;
    };

  };
};


    