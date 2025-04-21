import Enums "mo:waterway-mops/Enums";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Order "mo:base/Order";
import Buffer "mo:base/Buffer";
import F1DriverQueries "../queries/f1_driver_queries";
import F1DriverCommands "../commands/f1_driver_commands";

import Types "../data-types/types";

module {
  public class F1DriverManager() {

    private var f1Drivers: [Types.F1Driver] = [];

    public func getF1Driver(dto: F1DriverQueries.GetF1Driver) : Result.Result<F1DriverQueries.F1Driver, Enums.Error> {
      let f1Driver = Array.find<Types.F1Driver>(f1Drivers, func(f1Driver: Types.F1Driver) : Bool {
        f1Driver.id == dto.f1DriverId;
      });
      switch(f1Driver) {
        case(?foundF1Driver) { 
          return #ok({
            firstName = foundF1Driver.firstName;
            f1DriverId = foundF1Driver.id;
            lastName = foundF1Driver.lastName;
            nationality = foundF1Driver.nationality;
            f1TeamId = foundF1Driver.f1TeamId;
          });
        };
        case(null) {
          return #err(#NotFound);
        };
      };
    };

    public func listF1Drivers(dto: F1DriverQueries.ListF1Drivers) : Result.Result<F1DriverQueries.F1Drivers, Enums.Error> {
      
      return #ok({
        entries = Array.map<Types.F1Driver, F1DriverQueries.F1DriverSummary>(f1Drivers, func(entry: Types.F1Driver){
          return {
            f1DriverId = entry.id;
            firstName = entry.firstName;
            lastName = entry.lastName;
            nationality = entry.nationality;
            f1TeamId = entry.f1TeamId;
          }
        });
        page = dto.page;
        totalEntries = Array.size(f1Drivers);
      });
    };

    public func createF1Driver(dto: F1DriverCommands.CreateF1Driver) : Result.Result<(), Enums.Error> {

      let sortedF1Drivers = Array.sort(f1Drivers, func(a: Types.F1Driver, b: Types.F1Driver) : Order.Order {
        if (a.id > b.id) { #less } 
        else if (a.id < b.id) { #greater }
        else { #equal }
      });

      var nextId: Nat16 = 1;

      if(Array.size(sortedF1Drivers) > 0){
        nextId := sortedF1Drivers[0].id + 1;
      };

      let f1DriverBuffer = Buffer.fromArray<Types.F1Driver>(sortedF1Drivers);
      f1DriverBuffer.add({
        firstName = dto.firstName;
        id = nextId;
        lastName = dto.lastName;
        nationality = dto.nationality;
        f1TeamId = dto.f1TeamId;
      });

      return #ok();
    };  

    public func updateF1Driver(dto: F1DriverCommands.UpdateF1Driver) : Result.Result<(), Enums.Error> {

      //validate

      let f1Driver = Array.find(f1Drivers, func(entry: Types.F1Driver) : Bool {
        entry.id == dto.f1DriverId
      });
      switch(f1Driver){
        case (?_){
          
          f1Drivers := Array.map<Types.F1Driver, Types.F1Driver>(f1Drivers, func(entry: Types.F1Driver){
            if(entry.id == dto.f1DriverId){
              return {
                id = entry.id;
                firstName = dto.firstName;
                lastName = dto.lastName;
                nationality = dto.nationality;
                f1TeamId = dto.f1TeamId;
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

    public func getStableF1Drivers() : [Types.F1Driver] {
      return f1Drivers;
    };

    public func setStableF1Drivers(stable_f1_drivers: [Types.F1Driver]) {
      f1Drivers := stable_f1_drivers;
    };


  };
};
