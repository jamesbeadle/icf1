
import Result "mo:base/Result";
import Array "mo:base/Array";
import List "mo:base/List";
import Buffer "mo:base/Buffer";
import Nat8 "mo:base/Nat8";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Enums "mo:waterway-mops/Enums";
import Types "../data-types/types";
import FantasyLeaderboardQueries "../queries/fantasy_leaderboard_queries";
import Environment "../environment";
import F1TeamQueries "../queries/f1_team_queries";

module {
    public class FantasyLeaderboardManager() {

        private var leaderboards: [Types.FantasyLeaderboard] = [];

        public func getLeaderboard(dto: FantasyLeaderboardQueries.GetFantasyLeaderboard) : Result.Result<FantasyLeaderboardQueries.FantasyLeaderboard, Enums.Error> {
            let leaderboard = Array.find(leaderboards, func(entry: Types.FantasyLeaderboard) : Bool {
                entry.raceId == dto.raceId
            });

            switch(leaderboard){
                case (?foundLeaderboard){

                    let allEntries = List.fromArray(foundLeaderboard.entries);
                    let startIndex = dto.page * Environment.PAGINATION_ROW_COUNT;
                    let droppedEntries = List.drop<Types.FantasyLeaderboardEntry>(allEntries, startIndex);
                    let paginatedEntires = List.take<Types.FantasyLeaderboardEntry>(droppedEntries, Environment.PAGINATION_ROW_COUNT);

                    return #ok({
                        entries = List.toArray(paginatedEntires);
                        raceId = foundLeaderboard.raceId;
                        page = dto.page;
                        totalEntries = List.size(allEntries);
                    });
                };
                case (null){
                    return #err(#NotFound);
                }
            };
        };

        public func addChunkToLeaderboard(raceId: Types.RaceId, year: Nat16, chunk: [Types.Prediction]) {
            
            let existingLeaderboard = Array.find<Types.FantasyLeaderboard>(leaderboards, func(entry: Types.FantasyLeaderboard) : Bool {
                entry.raceId == raceId;
            });

            switch(existingLeaderboard){
                case(?foundLeaderboard){

                    let entriesBuffer = Buffer.fromArray<Types.FantasyLeaderboardEntry>(foundLeaderboard.entries);
                    
                    let mappedPredictions = Array.map<Types.Prediction, Types.FantasyLeaderboardEntry>(chunk, func(entry: Types.Prediction){
                        return {
                            principalId = entry.principalId;
                            username = entry.username;
                            points = 0;
                            position = 0;
                            positionText = "";
                        }
                    });

                    entriesBuffer.append(Buffer.fromArray(mappedPredictions));

                    let updatedLeaderboard: Types.FantasyLeaderboard = {
                        entries = Buffer.toArray(entriesBuffer);
                        raceId = foundLeaderboard.raceId;
                        totalEntries = foundLeaderboard.totalEntries;
                        year = foundLeaderboard.year;
                    };

                    let leaderboardBuffer = Buffer.fromArray<Types.FantasyLeaderboard>(leaderboards);
                    leaderboardBuffer.add(updatedLeaderboard);
                    leaderboards := Buffer.toArray(leaderboardBuffer);
                    
                };
                case (null){

                    let newLeaderboard: Types.FantasyLeaderboard = {
                        entries = Array.map<Types.Prediction, Types.FantasyLeaderboardEntry>(chunk, func(entry: Types.Prediction){
                            return {
                                principalId = entry.principalId;
                                username = entry.username;
                                points = 0;
                                position = 0;
                                positionText = "";
                            }
                        });
                        raceId = raceId;
                        totalEntries = 0;
                        year = year;
                    };
                    
                    let leaderboardBuffer = Buffer.fromArray<Types.FantasyLeaderboard>(leaderboards);
                    leaderboardBuffer.add(newLeaderboard);
                    leaderboards := Buffer.toArray(leaderboardBuffer);
                }
            };
        };

        public func calculateLeaderboard(raceId: Types.RaceId, year: Nat16) {

            let raceLeaderboard = Array.find<Types.FantasyLeaderboard>(leaderboards, func(entry: Types.FantasyLeaderboard) : Bool {
                entry.raceId == raceId and entry.year == year
            });

            switch(raceLeaderboard){
                case (?foundLeaderboard){
                    

                    let sortedEntries = Array.sort(
                        foundLeaderboard.entries,
                        func(entry1 : Types.FantasyLeaderboardEntry, entry2 : Types.FantasyLeaderboardEntry) : Order.Order {
                            if (entry1.points < entry2.points) { return #greater };
                            if (entry1.points == entry2.points) { return #equal };
                            return #less;
                        },
                    );

                    let positionedEntries = assignPositionText(List.fromArray<Types.FantasyLeaderboardEntry>(sortedEntries));

                    var updatedLeaderboard : Types.FantasyLeaderboard = {

                        raceId = foundLeaderboard.raceId;
                        year = foundLeaderboard.year;
                        entries = List.toArray(positionedEntries);
                        totalEntries = List.size(positionedEntries);
                    };

                    let leaderboardBuffer = Buffer.fromArray<Types.FantasyLeaderboard>(
                    Array.filter<Types.FantasyLeaderboard>(
                        leaderboards,
                        func(leaderboard : Types.FantasyLeaderboard) {
                        return not (leaderboard.raceId == raceId and leaderboard.year == year);
                        },
                    )
                    );

                    leaderboardBuffer.add(updatedLeaderboard);
                    leaderboards := Buffer.toArray(leaderboardBuffer);

                };
                case (null){};
            };
        };

        private func assignPositionText(sortedEntries : List.List<Types.FantasyLeaderboardEntry>) : List.List<Types.FantasyLeaderboardEntry> {
            var position = 1;
            var previousPoints : ?Int8 = null;
            var currentPosition = 1;

            func updatePosition(entry : Types.FantasyLeaderboardEntry) : Types.FantasyLeaderboardEntry {
            if (previousPoints == null) {
                previousPoints := ?entry.points;
                let updatedEntry = {
                entry with position = position;
                positionText = Int.toText(position);
                };
                currentPosition += 1;
                return updatedEntry;
            } else if (previousPoints == ?entry.points) {
                currentPosition += 1;
                return { entry with position = position; positionText = "-" };
            } else {
                position := currentPosition;
                previousPoints := ?entry.points;
                let updatedEntry = {
                entry with position = position;
                positionText = Int.toText(position);
                };
                currentPosition += 1;
                return updatedEntry;
            };
            };

            return List.map(sortedEntries, updatePosition);
        };  

        public func getStableLeaderboards() : [Types.FantasyLeaderboard] {
            return leaderboards;
        };

        public func setStableLeaderboards(stable_leaderboards : [Types.FantasyLeaderboard]) : () {
            leaderboards := stable_leaderboards;
        };
    };
};
