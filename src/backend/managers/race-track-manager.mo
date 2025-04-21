import Types "../data-types/types";
import RaceTrackCommands "../commands/race_track_commands";
import RaceTrackQueries "../queries/race_track_queries";
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
  public class RaceTrackManager() {

    private var raceTracks: [Types.RaceTrack] = [];

    public func getRaceTrack(dto: RaceTrackQueries.GetRaceTrack) : Result.Result<RaceTrackQueries.RaceTrack, Enums.Error> {
      let raceTrack = Array.find(raceTracks, func(entry: Types.RaceTrack) : Bool {
        entry.id == dto.raceId
      });
      switch(raceTrack){
        case (?foundRaceTrack){
          return #ok({
            raceTrackId = foundRaceTrack.id;
          });
        };
        case (null){
          return #err(#NotFound); 
        }
      }
    };
    
    public func listRaceTracks(dto: RaceTrackQueries.ListRaceTracks) : Result.Result<RaceTrackQueries.RaceTracks, Enums.Error> {
      
      let allEntries = List.fromArray(raceTracks);
      let startIndex = dto.page * Environment.PAGINATION_ROW_COUNT;
      let droppedEntries = List.drop<Types.RaceTrack>(allEntries, startIndex);
      let paginatedEntires = List.take<Types.RaceTrack>(droppedEntries, Environment.PAGINATION_ROW_COUNT);
      let mappedEntries = List.map<Types.RaceTrack, RaceTrackQueries.RaceTrackSummary>(paginatedEntires, func(entry: Types.RaceTrack){
        return {
          name = entry.name;
          raceId = entry.id;
        }
      });

      return #ok({
        entries = List.toArray<RaceTrackQueries.RaceTrackSummary>(mappedEntries);
        page = dto.page;
        totalEntries = List.size(allEntries);
      });
    };

    public func createRaceTrack(dto: RaceTrackCommands.CreateRaceTrack) : Result.Result<(), Enums.Error> {

      let sortedRaceTracks = Array.sort(raceTracks, func(a: Types.RaceTrack, b: Types.RaceTrack) : Order.Order {
        if (a.id > b.id) { #less } 
        else if (a.id < b.id) { #greater }
        else { #equal }
      });

      var nextId: Nat16 = 1;

      if(Array.size(sortedRaceTracks) > 0){
        nextId := sortedRaceTracks[0].id + 1;
      };

      let raceTracksBuffer = Buffer.fromArray<Types.RaceTrack>(raceTracks);
      raceTracksBuffer.add({
        id = nextId;
        name = dto.name;
      });

      return #ok();
    };

    public func getStableRaceTracks() : [Types.RaceTrack] {
      return raceTracks;
    };

    public func setStableRaceTracks(stable_raceTracks : [Types.RaceTrack]) {
      raceTracks := stable_raceTracks;
    };

  };
};


    