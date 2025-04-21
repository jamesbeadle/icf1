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
import Enums "mo:waterway-mops/Enums";
import Ids "mo:waterway-mops/Ids";
import Environment "../environment";


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
      let existingPrediction = Array.find(predictions, func(entry: Types.Prediction) : Bool {
        entry.principalId == principalId
      });
      
      switch(existingPrediction){
        case (?foundPrediction){
          predictions := Array.map<Types.Prediction, Types.Prediction>(predictions, func(entry: Types.Prediction){
            if(entry.principalId == principalId){
              return {
                createdOn = foundPrediction.createdOn;
                principalId = foundPrediction.principalId;
                totalPoints = foundPrediction.totalPoints;
                raceId = foundPrediction.raceId;
                username = foundPrediction.username;
                year = foundPrediction.year;
              }
            };
            return entry;
          });
        };
        case (null){
          let newPrediction: Types.Prediction = {
            createdOn = Time.now();
            principalId = principalId;
            points = 0;
            raceId = dto.raceId;
            username = username;
            year = dto.year;
            swap1Used = false;
            swap2Used = false;
            swap3Used = false;
          };
          
          let predictionBuffer = Buffer.fromArray<Types.Prediction>(predictions);
          predictionBuffer.add(newPrediction);
          predictions := Buffer.toArray<Types.Prediction>(predictionBuffer);
        }
      };

      return #ok();
    };

    public func calculateF1PredictionPoints(leaderboard: Types.RaceLeaderboard, raceTrack: RaceTrackQueries.RaceTrack) {
    
      let predictionBuffer = Buffer.fromArray<Types.Prediction>(predictions);
    
      for (i in Iter.range(0, predictions.size() - 1)) {
        let prediction = predictions[i];
        
        let updatedPrediction : Types.Prediction = {
            createdOn = prediction.createdOn;
            principalId = prediction.principalId;
            raceId = prediction.raceId;
            username = prediction.username;
            year = prediction.year;
            points = points;
        };
        
        predictionBuffer.put(i, updatedPrediction);
      };
    
      predictions := Buffer.toArray(predictionBuffer);
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


    