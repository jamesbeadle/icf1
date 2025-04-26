/* ----- Mops Packages ----- */

import BaseQueries "mo:waterway-mops/queries/BaseQueries";
import BaseTypes "mo:waterway-mops/BaseTypes";
import Enums "mo:waterway-mops/Enums";
import Ids "mo:waterway-mops/Ids";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Timer "mo:base/Timer";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import CanisterIds "mo:waterway-mops/CanisterIds";

/* ----- Queries ----- */

import UserQueries "queries/user_queries";
import F1TeamQueries "queries/f1_team_queries";
import F1DriverQueries "queries/f1_driver_queries";
import CanisterQueries "mo:waterway-mops/canister-management/CanisterQueries";

/* ----- Commands ----- */

import UserCommands "commands/user_commands";
import F1TeamCommands "commands/f1_team_commands";
import F1DriverCommands "commands/f1_driver_commands";
import RaceCommands "commands/race_commands";
import FantasyLeaderboardCommands "commands/fantasy_leaderboard_commands";

/* ----- Manager ----- */

import UserManager "managers/user-manager";
import F1TeamManager "managers/f1-team-manager";
import F1DriverManager "managers/f1-driver-manager";
import FantasyLeaderboardManager "managers/fantasy-leaderboard-manager";
import RaceManager "managers/race-manager";

/* ----- Type imports for stable variables ----- */

import Types "./data-types/types";
import Environment "environment";
import FantasyLeaderboardQueries "queries/fantasy_leaderboard_queries";
import MopsBaseCommands "mops_base_commands";
import RaceQueries "queries/race_queries";
import RaceTrackQueries "queries/race_track_queries";
import RaceTrackCommands "commands/race_track_commands";
import RaceTrackManager "managers/race-track-manager";

actor Self {

  /* ----- Stable Canister Variables ----- */

  private stable var stable_profiles : [Types.Profile] = [];
  private stable var stable_fantasy_leaderboards : [Types.FantasyLeaderboard] = [];
  private stable var stable_predictions : [Types.Prediction] = [];
  private stable var stable_f1_drivers : [Types.F1Driver] = [];
  private stable var stable_f1_teams : [Types.F1Team] = [];
  private stable var stable_races : [Types.Race] = [];

  private stable var appStatus : BaseTypes.AppStatus = {
    onHold = false;
    version = "0.0.1";
  };

  /* ----- Manager Initialisation with Transient Canister Variables ----- */

  private let userManager = UserManager.UserManager();
  private let fantasyLeaderboardManager = FantasyLeaderboardManager.FantasyLeaderboardManager();
  private let f1DriverManager = F1DriverManager.F1DriverManager();
  private let f1TeamManager = F1TeamManager.F1TeamManager();
  private let raceManager = RaceManager.RaceManager();
  private let raceTrackManager = RaceTrackManager.RaceTrackManager();

  /* ----- App Queries and Commands ----- */

  public shared query func getAppStatus() : async Result.Result<BaseQueries.AppStatus, Enums.Error> {
    return #ok(appStatus);
  };

  public shared ({ caller }) func updateAppStatus(dto : MopsBaseCommands.UpdateAppStatus) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);

    appStatus := {
      onHold = dto.onHold;
      version = dto.version;
    };

    return #ok();
  };

  /* ----- User Queries and Commands ----- */

  public shared query ({ caller }) func isUsernameValid(dto : UserQueries.IsUsernameValid) : async Bool {
    assert not Principal.isAnonymous(caller);
    let usernameValid = validateUsernameFormat(dto.username);
    let usernameTaken = userManager.isUsernameTaken(dto.username, Principal.toText(caller));
    return usernameValid and not usernameTaken;
  };

  public shared query ({ caller }) func getProfile(_ : UserQueries.GetProfile) : async Result.Result<UserQueries.Profile, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    return userManager.getProfile(principalId);
  };

  public shared query ({ caller }) func getPrediction(dto : UserQueries.GetPrediction) : async Result.Result<UserQueries.Prediction, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    return userManager.getPrediction(principalId, dto);
  };

  public shared query ({ caller }) func listPredictions(dto : UserQueries.ListPredictions) : async Result.Result<UserQueries.Predictions, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    return userManager.listPredictions(principalId, dto);
  };

  public shared query ({ caller }) func getRaceCard(dto : UserQueries.GetRaceCard) : async Result.Result<UserQueries.Prediction, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return userManager.getRaceCard(dto);
  };

  public shared ({ caller }) func createProfile(dto : UserCommands.CreateProfile) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);

    if (Text.size(dto.username) < 3 or Text.size(dto.username) > 20) {
      return #err(#InvalidProperty);
    };

    let invalidUsername = userManager.isUsernameTaken(dto.username, principalId);
    if (invalidUsername) {
      return #err(#AlreadyExists);
    };

    return userManager.createProfile(principalId, dto);
  };

  public shared ({ caller }) func updateProfilePicture(dto : UserCommands.UpdateProfilePicture) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    return userManager.updateProfilePicture(principalId, dto);
  };

  public shared ({ caller }) func updateUsername(dto : UserCommands.UpdateUsername) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    return userManager.updateUsername(principalId, dto);
  };

  public shared ({ caller }) func submitPrediction(dto : UserCommands.SubmitPrediction) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    let user = userManager.getProfile(principalId);
    switch(user){
      case (#ok foundUser){
        return userManager.submitPrediction(principalId, foundUser.username, dto);
      };
      case (_){ return #err(#NotFound) }
    }
  };

  /* ----- F1 Team Queries and Commands ----- */

  public shared query ({ caller }) func getF1Team(dto : F1TeamQueries.GetF1Team) : async Result.Result<F1TeamQueries.F1Team, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return f1TeamManager.getF1Team(dto);
  };

  public shared query ({ caller }) func listF1Teams(dto : F1TeamQueries.ListF1Teams) : async Result.Result<F1TeamQueries.F1Teams, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return f1TeamManager.listF1Teams(dto);
  };

  public shared ({ caller }) func createF1Team(dto : F1TeamCommands.CreateF1Team) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);
    return f1TeamManager.createF1Team(dto);
  };

  public shared ({ caller }) func updateF1Team(dto : F1TeamCommands.UpdateF1Team) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);
    return f1TeamManager.updateF1Team(dto);
  };

  /* ----- F1 Driver Queries and Commands ----- */

  public shared query ({ caller }) func getF1Driver(dto : F1DriverQueries.GetF1Driver) : async Result.Result<F1DriverQueries.F1Driver, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return f1DriverManager.getF1Driver(dto);
  };

  public shared query ({ caller }) func listF1Drivers(dto : F1DriverQueries.ListF1Drivers) : async Result.Result<F1DriverQueries.F1Drivers, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return f1DriverManager.listF1Drivers(dto);
  };

  public shared ({ caller }) func createF1Driver(dto : F1DriverCommands.CreateF1Driver) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);
    return f1DriverManager.createF1Driver(dto);
  };

  public shared ({ caller }) func updateF1Driver(dto : F1DriverCommands.UpdateF1Driver) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);
    return f1DriverManager.updateF1Driver(dto);
  };

  /* ----- Leaderboard Queries ----- */

  public shared query ({ caller }) func getLeaderboard(dto : FantasyLeaderboardQueries.GetFantasyLeaderboard) : async Result.Result<FantasyLeaderboardQueries.FantasyLeaderboard, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return fantasyLeaderboardManager.getLeaderboard(dto);
  };

  /* ----- Race Queries and Commands ----- */

  public shared query ({ caller }) func getRace(dto: RaceQueries.GetRace) : async Result.Result<RaceQueries.Race, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return raceManager.getRace(dto);
  };

  public shared query ({ caller }) func listRaces(dto: RaceQueries.ListRaces) : async Result.Result<RaceQueries.Races, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return raceManager.listRaces(dto);
  };

  public shared ({ caller }) func createRace(dto: RaceCommands.CreateRace) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);
    return raceManager.createRace(dto);  
  };

  public shared ({ caller }) func updateRaceStage(dto : RaceCommands.UpdateRaceStage) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);
    return raceManager.updateRaceStage(dto);
  };

  public shared ({ caller }) func calculateLeaderboard(dto : FantasyLeaderboardCommands.CalculateLeaderboard) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);
    fantasyLeaderboardManager.calculateLeaderboard(dto.raceId, dto.year);
    return #ok();
  };


  /* ----- Race Track Queries and Commands ----- */

  public shared query ({ caller }) func getRaceTrack(dto: RaceTrackQueries.GetRaceTrack) : async Result.Result<RaceTrackQueries.RaceTrack, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return raceTrackManager.getRaceTrack(dto);
  };
  
  public shared query ({ caller }) func listRaceTracks(dto: RaceTrackQueries.ListRaceTracks) : async Result.Result<RaceTrackQueries.RaceTracks, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    return raceTrackManager.listRaceTracks(dto);
  };

  public shared ({ caller }) func createRaceTrack(dto: RaceTrackCommands.CreateRaceTrack) : async Result.Result<(), Enums.Error> {
    assert not Principal.isAnonymous(caller);
    let principalId = Principal.toText(caller);
    assert await isAdmin(principalId);
    return raceTrackManager.createRaceTrack(dto);  
  };

  /* ----- Private Functions ----- */

  public func isAdmin(principalId : Text) : async Bool {
    let foundPrincipalId = Array.find(
      Environment.ADMIN_PRINCIPAL_IDS,
      func(entry : Ids.PrincipalId) : Bool {
        entry == principalId;
      },
    );
    switch (foundPrincipalId) {
      case (?foundPrincipalId) {
        return true;
      };
      case (null) {
        return false;
      };
    };
  };

  private func validateUsernameFormat(username : Text) : Bool {
    if (Text.size(username) < 3 or Text.size(username) > 20) {
      return false;
    };

    let isAlphanumeric = func(s : Text) : Bool {
      let chars = Text.toIter(s);
      for (c in chars) {
        if (not ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or (c == ' '))) {
          return false;
        };
      };
      return true;
    };

    if (not isAlphanumeric(username)) {
      return false;
    };
    return true;
  };

  private func transferLeaderboardChunks(raceId : Types.RaceId, year : Nat16) {
    let totalEntries : Nat = userManager.getTotalLeaderboardEntries(raceId);
    var totalChunks = totalEntries / Environment.ENTRY_TRANSFER_LIMIT;
    let remainder = totalEntries % Environment.ENTRY_TRANSFER_LIMIT;

    if (remainder > 0) { totalChunks += 1 };

    for (chunk in Iter.range(0, totalChunks - 1)) {
      let leaderboardChunk = userManager.getLeaderboardChunk(raceId, year, chunk);
      fantasyLeaderboardManager.addChunkToLeaderboard(raceId, year, leaderboardChunk);
    };

    raceManager.setPopulated(raceId, year);
  };

  /* ----- Canister Lifecycle ----- */

  system func preupgrade() {
    stable_profiles := userManager.getStableProfiles();
    stable_predictions := userManager.getStablePredictions();
    stable_f1_drivers := f1DriverManager.getStableF1Drivers();
    stable_f1_teams := f1TeamManager.getStableF1Teams();
    stable_fantasy_leaderboards := fantasyLeaderboardManager.getStableLeaderboards();
    stable_races := raceManager.getStableRaces();
  };

  system func postupgrade() {
    ignore Timer.setTimer<system>(#nanoseconds(Int.abs(1)), postUpgradeCallback);
  };

  private func postUpgradeCallback() : async () {
    userManager.setStableProfiles(stable_profiles);
    userManager.setStablePredictions(stable_predictions);
    f1DriverManager.setStableF1Drivers(stable_f1_drivers);
    f1TeamManager.setStableF1Teams(stable_f1_teams);
    fantasyLeaderboardManager.setStableLeaderboards(stable_fantasy_leaderboards);
    raceManager.setStableRaces(stable_races);
  };

  /* ----- WWL Canister Management ----- */
  public shared ({ caller }) func getProjectCanisters() : async Result.Result<CanisterQueries.ProjectCanisters, Enums.Error> {
    assert not Principal.isAnonymous(caller);
    assert Principal.toText(caller) == CanisterIds.WATERWAY_LABS_BACKEND_CANISTER_ID;

    var projectCanisters : [CanisterQueries.Canister] = [];

    var backend_dto : CanisterQueries.Canister = {
      canisterId = CanisterIds.ICF1_BACKEND_CANISTER_ID;
      canisterType = #Static;
      canisterName = "ICF1 Backend Canister";
      app = #ICF1;
    };
    projectCanisters := Array.append<CanisterQueries.Canister>(projectCanisters, [backend_dto]);

    let frontend_dto : CanisterQueries.Canister = {
      canisterId = Environment.ICF1_FRONTEND_CANISTER_ID;
      canisterType = #Static;
      canisterName = "ICF1 Frontend Canister";
      app = #ICF1;
    };
    projectCanisters := Array.append<CanisterQueries.Canister>(projectCanisters, [frontend_dto]);

    let res : CanisterQueries.ProjectCanisters = {
      entries = projectCanisters;
    };
    return #ok(res);
  };
};
