import Types "../data-types/types";
import UserQueries "../queries/user_queries";
import UserCommands "../commands/user_commands";
import Result "mo:base/Result";
import Array "mo:base/Array";
import List "mo:base/List";
import Order "mo:base/Order";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Int8 "mo:base/Int8";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Nat16 "mo:base/Nat16";
import Enums "mo:waterway-mops/Enums";
import Ids "mo:waterway-mops/Ids";
import Environment "../environment";
import RaceTrackQueries "../queries/race_track_queries";

module {
  public class UserManager() {

    private var profiles: [Types.Profile] = [];
    private var predictions: [Types.Prediction] = [];

    public func isUsernameTaken(username : Text, principalId : Text) : Bool {
      for (profile in Iter.fromArray(profiles)) {

        let lowerCaseUsername = toLowercase(username);
        let existingUsername = toLowercase(profile.username);

        if (lowerCaseUsername == existingUsername and profile.username != principalId) {
          return true;
        };
      };

      return false;
    };

    private func toLowercase(t : Text.Text) : Text.Text {
        func charToLower(c : Char) : Char {
            if (Char.isUppercase(c)) {
                Char.fromNat32(Char.toNat32(c) + 32);
            } else {
                c;
            };
        };
        Text.map(t, charToLower);
    };

    public func getProfile(principalId: Ids.PrincipalId) : Result.Result<UserQueries.Profile, Enums.Error> {
      let profile = Array.find(profiles, func(entry: Types.Profile) : Bool {
        entry.principalId == principalId
      });
      switch(profile){
        case (?foundProfile){
          return #ok({
            joinedOn = foundProfile.joinedOn;
            principalId = foundProfile.principalId;
            username = foundProfile.username;
          })
        };
        case (null){ 
          return #err(#NotFound);
        }
      };
    };

    public func getPrediction(principalId: Ids.PrincipalId, dto: UserQueries.GetPrediction) : Result.Result<UserQueries.Prediction, Enums.Error> {
      return getPredictionRaceCard(principalId, dto.raceId, dto.year);
    };

    public func getRaceCard(dto: UserQueries.GetRaceCard) : Result.Result<UserQueries.Prediction, Enums.Error> {
      return getPredictionRaceCard(dto.principalId, dto.raceId, dto.year);
    };

    private func getPredictionRaceCard(principalId: Ids.PrincipalId, raceId: Types.RaceId, year: Nat16) : Result.Result<UserQueries.Prediction, Enums.Error> {
      let prediction = Array.find(predictions, func(entry: Types.Prediction) : Bool {
        entry.principalId == principalId and entry.raceId == raceId and entry.year == year;
      });
      switch(prediction){
        case (?foundPrediction){
          
          // TODO
          return #err(#NotFound);
        };
        case (null){ 
          return #err(#NotFound);
        }
      };
    };

    public func listPredictions(principalId: Ids.PrincipalId, dto: UserQueries.ListPredictions) : Result.Result<UserQueries.Predictions, Enums.Error> {

      let userPredictions = Array.filter<Types.Prediction>(predictions, func(entry: Types.Prediction){
        entry.principalId == principalId;
      });
      let allEntries = List.fromArray(userPredictions);
      let startIndex = dto.page * Environment.PAGINATION_ROW_COUNT;
      let droppedEntries = List.drop<Types.Prediction>(allEntries, startIndex);
      let paginatedEntires = List.take<Types.Prediction>(droppedEntries, Environment.PAGINATION_ROW_COUNT);
      let mappedEntries = List.map<Types.Prediction, UserQueries.PredictionSummary>(paginatedEntires, func(entry: Types.Prediction){
        return {
          principalId = principalId;
          points = entry.points;
          raceId = entry.raceId;
          year = entry.year;
          createdOn = entry.createdOn;
        }
      });

      let sortedPredictions = Array.sort(List.toArray(mappedEntries), func(a: UserQueries.PredictionSummary, b: UserQueries.PredictionSummary) : Order.Order {
        if (a.createdOn > b.createdOn) { #less } 
        else if (a.createdOn < b.createdOn) { #greater }
        else { #equal }
      });

      return #ok({
        entries = sortedPredictions;
        page = dto.page;
        totalEntries = List.size(allEntries);
      });
    };

    public func createProfile(principalId: Ids.PrincipalId, dto: UserCommands.CreateProfile) : Result.Result<(), Enums.Error> {
      let existingProfile = Array.find(profiles, func(profile: Types.Profile) : Bool {
        profile.principalId == principalId;
      });
      switch(existingProfile) {
        case(?_) { 
          return #err(#AlreadyExists);   
        };
        case(null) {
          
          let newProfile: Types.Profile = {
            joinedOn = Time.now();
            principalId;
            profilePicture = dto.profilePicture;
            username = dto.username;
          };

          let profileBuffer = Buffer.fromArray<Types.Profile>(profiles);
          profileBuffer.add(newProfile);
          profiles := Buffer.toArray(profileBuffer);

          return #ok();
        };
      };
    };

    public func updateProfilePicture(principalId: Ids.PrincipalId, dto: UserCommands.UpdateProfilePicture) : Result.Result<(), Enums.Error> {
      let existingProfile = Array.find(profiles, func(profile: Types.Profile) : Bool {
        profile.principalId == principalId;
      });
      switch(existingProfile) {
        case(?foundProfile) { 
          
          let updatedProfile: Types.Profile = {
            joinedOn = foundProfile.joinedOn;
            principalId = foundProfile.principalId;
            profilePicture = dto.profilePicture;
            username = foundProfile.username;
          };

          profiles := Array.map<Types.Profile, Types.Profile>(profiles, func(entry: Types.Profile){
            if(entry.principalId == principalId){
              return updatedProfile;
            };
            return entry;
          });

          return #ok();
        };
        case(null) {
          return #err(#NotFound);   
        };
      };
    };

    public func updateUsername(principalId: Ids.PrincipalId, dto: UserCommands.UpdateUsername) : Result.Result<(), Enums.Error> {
      let existingProfile = Array.find(profiles, func(profile: Types.Profile) : Bool {
        profile.principalId == principalId;
      });
      switch(existingProfile) {
        case(?foundProfile) { 
          
          let updatedProfile: Types.Profile = {
            joinedOn = foundProfile.joinedOn;
            principalId = foundProfile.principalId;
            profilePicture = foundProfile.profilePicture;
            username = dto.username;
          };

          profiles := Array.map<Types.Profile, Types.Profile>(profiles, func(entry: Types.Profile){
            if(entry.principalId == principalId){
              return updatedProfile;
            };
            return entry;
          });

          return #ok();
        };
        case(null) {
          return #err(#NotFound);   
        };
      };
    };


    public func submitPrediction(principalId: Ids.PrincipalId, username: Text, dto: UserCommands.SubmitPrediction) : Result.Result<(), Enums.Error> {
        if (dto.teamSelections.size() != 10) {
            return #err(#InvalidData);
        };

        let teamIds = Array.map(dto.teamSelections, func (sel: Types.TeamSelection) : Types.F1TeamId { sel.f1TeamId });
        let uniqueTeamIds = Array.sort(teamIds, Nat16.compare);
        let hasDuplicates = Array.size(uniqueTeamIds) != Array.size(teamIds);
        if (hasDuplicates) {
            return #err(#InvalidData);
        };

        let existingPrediction = Array.find(predictions, func(entry: Types.Prediction) : Bool {
            entry.principalId == principalId and entry.raceId == dto.raceId and entry.year == dto.year
        });
        
        switch(existingPrediction) {
            case (?_) {
                predictions := Array.map<Types.Prediction, Types.Prediction>(predictions, func(entry: Types.Prediction) {
                    if (entry.principalId == principalId and entry.raceId == dto.raceId and entry.year == dto.year) {
                        return {
                            createdOn = Time.now();
                            principalId = principalId;
                            points = 0;
                            raceId = dto.raceId;
                            username = username;
                            year = dto.year;
                            teamSelections = dto.teamSelections;
                        }
                    };
                    return entry;
                });
            };
            case (null) {
                let newPrediction: Types.Prediction = {
                    createdOn = Time.now();
                    principalId = principalId;
                    points = 0;
                    raceId = dto.raceId;
                    username = username;
                    year = dto.year;
                    teamSelections = dto.teamSelections;
                };
                
                let predictionBuffer = Buffer.fromArray<Types.Prediction>(predictions);
                predictionBuffer.add(newPrediction);
                predictions := Buffer.toArray(predictionBuffer);
            }
        };

        return #ok();
    };

    public func calculateF1PredictionPoints(leaderboard: Types.RaceLeaderboard) {
        let predictionBuffer = Buffer.fromArray<Types.Prediction>(predictions);
        
        for (i in Iter.range(0, predictions.size() - 1)) {
            let prediction = predictions[i];
            
            var teamDriverOrderScores: Nat16 = 0;
            var teamBestDriverOrderScores: Nat16 = 0;
            var driverBonusesPlayedScores: Nat16 = 0;

            for (selection in Iter.fromArray(prediction.teamSelections)) {
                let leadDriverEntry = Array.find(leaderboard.entries, func (entry: Types.RaceLeaderboardEntry) : Bool {
                    entry.f1DriverId == selection.leadDriver
                });
                let secondDriverEntry = Array.find(leaderboard.entries, func (entry: Types.RaceLeaderboardEntry) : Bool {
                    entry.f1DriverId == selection.secondDriver
                });

                switch (leadDriverEntry, secondDriverEntry) {
                    case (?lead, ?second) {
                        let leadPosition = Array.indexOf(lead, leaderboard.entries, func(a: Types.RaceLeaderboardEntry, b: Types.RaceLeaderboardEntry) : Bool { a == b });
                        let secondPosition = Array.indexOf(second, leaderboard.entries, func(a: Types.RaceLeaderboardEntry, b: Types.RaceLeaderboardEntry) : Bool { a == b });
                        
                        switch (leadPosition, secondPosition) {
                            case (?lp, ?sp) {
                                if (lp < sp) { 
                                    teamDriverOrderScores += 20;
                                }
                            };
                            case _ {  }
                        };
                    };
                    case _ {  }
                };
            };

            let actualTeamOrder = Array.map<Types.RaceLeaderboardEntry, (Types.F1TeamId, Nat)>(leaderboard.entries, func (entry: Types.RaceLeaderboardEntry) : (Types.F1TeamId, Nat) {
                let driver = getDriverById(entry.f1DriverId);
                let leaderboardEntry = Array.indexOf(entry, leaderboard.entries, func(a: Types.RaceLeaderboardEntry, b: Types.RaceLeaderboardEntry) : Bool { a == b });
                switch (leaderboardEntry) {
                    case (?foundEntry) {
                        (driver.f1TeamId, foundEntry)
                    };
                    case (null) {
                        (driver.f1TeamId, leaderboard.entries.size())
                    };
                };
            });
            
            let sortedActualTeamOrder = Array.sort(actualTeamOrder, func(a: (Types.F1TeamId, Nat), b: (Types.F1TeamId, Nat)) : Order.Order {
                Nat.compare(a.1, b.1)
            });

            let predictedTeamOrder = Array.map(prediction.teamSelections, func (sel: Types.TeamSelection) : Types.F1TeamId { sel.f1TeamId });
            var correctTeams = 0;
            label compare for (i in Iter.range(0, Nat.min(4, Nat.min(Array.size(predictedTeamOrder) - 1, Array.size(sortedActualTeamOrder) - 1)))) {
                if (predictedTeamOrder[i] == sortedActualTeamOrder[i].0) {
                    correctTeams += 1;
                } else {
                    break compare;
                };
            };

            teamBestDriverOrderScores := switch(correctTeams) {
                case 1 { 10 };
                case 2 { 25 };
                case 3 { 50 };
                case 4 { 100 };
                case 5 { 200 };
                case _ { 0 };
            };

            for (selection in Iter.fromArray(prediction.teamSelections)) {
               
                for (bonus in Iter.fromArray(selection.leadDriverBonuses)) {
                    driverBonusesPlayedScores += switch(bonus) {
                        case (#OnPole) { if (isOnPole(selection.leadDriver, leaderboard)) 25 else 0 };
                        case (#FastestLap) { if (hasFastestLap(selection.leadDriver, leaderboard)) 150 else 0 };
                        case (#WinsRace) { if (isRaceWinner(selection.leadDriver, leaderboard)) 75 else 0 };
                        case (#FirstOut) { if (isFirstOut(selection.leadDriver, leaderboard)) 200 else 0 };
                        case (#Lapped) { if (isLapped(selection.leadDriver, leaderboard)) 50 else 0 };
                        case (#DidNotFinish) { if (didNotFinish(selection.leadDriver, leaderboard)) 100 else 0 };
                    };
                };

                for (bonus in Iter.fromArray(selection.secondDriverBonuses)) {
                    driverBonusesPlayedScores += switch(bonus) {
                        case (#OnPole) { if (isOnPole(selection.secondDriver, leaderboard)) 25 else 0 };
                        case (#FastestLap) { if (hasFastestLap(selection.secondDriver, leaderboard)) 150 else 0 };
                        case (#WinsRace) { if (isRaceWinner(selection.secondDriver, leaderboard)) 75 else 0 };
                        case (#FirstOut) { if (isFirstOut(selection.secondDriver, leaderboard)) 200 else 0 };
                        case (#Lapped) { if (isLapped(selection.secondDriver, leaderboard)) 50 else 0 };
                        case (#DidNotFinish) { if (didNotFinish(selection.secondDriver, leaderboard)) 100 else 0 };
                    };
                };
            };

            let points: Nat16 = teamDriverOrderScores + teamBestDriverOrderScores + driverBonusesPlayedScores;

            let updatedPrediction: Types.Prediction = {
                createdOn = prediction.createdOn;
                principalId = prediction.principalId;
                raceId = prediction.raceId;
                username = prediction.username;
                year = prediction.year;
                points = points;
                teamSelections = prediction.teamSelections;
            };
            
            predictionBuffer.put(i, updatedPrediction);
        };
        
        predictions := Buffer.toArray(predictionBuffer);
    };

    private func getDriverById(driverId: Types.F1DriverId) : Types.F1Driver {
        // TODO: Implement actual driver lookup from storage
        {
            id = driverId;
            firstName = "";
            lastName = "";
            nationality = 0;
            f1TeamId = 0;
        }
    };

    private func isOnPole(driverId: Types.F1DriverId, leaderboard: Types.RaceLeaderboard) : Bool {
        // TODO: Implement logic to check if driver was on pole
        // Requires additional race data (e.g., qualifying results)
        false
    };

    private func hasFastestLap(driverId: Types.F1DriverId, leaderboard: Types.RaceLeaderboard) : Bool {
        // TODO: Implement logic to check if driver had fastest lap
        // Check RaceLeaderboardEntry.laps for fastest lap time
        false
    };

    private func isRaceWinner(driverId: Types.F1DriverId, leaderboard: Types.RaceLeaderboard) : Bool {
        if (leaderboard.entries.size() == 0) {
            return false;
        };
        let firstEntry = leaderboard.entries[0];
        firstEntry.f1DriverId == driverId
    };

    private func isFirstOut(driverId: Types.F1DriverId, leaderboard: Types.RaceLeaderboard) : Bool {
        // TODO: Implement logic to check if driver was first to retire
        // Check RaceLeaderboardEntry for first DNF or retirement data
        false
    };

    private func isLapped(driverId: Types.F1DriverId, leaderboard: Types.RaceLeaderboard) : Bool {
        // TODO: Implement logic to check if driver was lapped
        // Check RaceLeaderboardEntry.laps or raceTime
        false
    };

    private func didNotFinish(driverId: Types.F1DriverId, leaderboard: Types.RaceLeaderboard) : Bool {
        // TODO: Implement logic to check if driver did not finish
        // Check if driver is missing from leaderboard.entries or marked as DNF
        false
    };




    public func getTotalLeaderboardEntries(raceId: Types.RaceId) : Nat {
      let leaderboardEntries = Array.filter<Types.Prediction>(predictions, func(entry: Types.Prediction){
        entry.raceId == raceId
      });
      return Array.size(leaderboardEntries);
    };

    public func getLeaderboardChunk(raceId: Types.RaceId, year: Nat16, chunkIndex: Nat) : [Types.Prediction] {
      let racePredictions = Array.filter<Types.Prediction>(predictions, func(entry: Types.Prediction) : Bool {
        entry.raceId == raceId and entry.year == year
      });
      
      let startIndex = chunkIndex * Environment.ENTRY_TRANSFER_LIMIT;
      let endIndex = Nat.min(startIndex + Environment.ENTRY_TRANSFER_LIMIT, Array.size(racePredictions));
      
      if (startIndex >= Array.size(racePredictions)) {
        return [];
      };
      
      let chunkSizeInt = Int.sub(endIndex, startIndex);
      let chunkSize = if (chunkSizeInt >= 0) { Int.abs(chunkSizeInt) } else { 0 };
      
      let chunk = Array.subArray(racePredictions, startIndex, chunkSize);
      
      return chunk;
    };

    public func getStableProfiles() : [Types.Profile] {
      return profiles;
    };

    public func getStablePredictions() : [Types.Prediction] {
      return predictions;
    };

    public func setStableProfiles(stable_profiles: [Types.Profile]){
      profiles := stable_profiles;
    };

    public func setStablePredictions(stable_predictions: [Types.Prediction]){
      predictions := stable_predictions;
    };

  };
};


    