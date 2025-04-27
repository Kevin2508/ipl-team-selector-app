import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/team.dart';

class CsvService {
  Future<List<Team>> loadTeamsFromCsv() async {
    final rawData = await rootBundle.loadString('assets/data/ipl_players.csv');
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);

    // Skip header row
    final rows = csvTable.sublist(1);

    // Create a map to group players by team
    final Map<String, List<Player>> teamPlayersMap = {};

    for (var row in rows) {
      final name = row[0].toString();
      final teamName = row[1].toString();

      // Using placeholder image URLs - you'll replace this with actual URLs
      final imageUrl = 'https://placeholder.com/player-$name.jpg';

      final player = Player(
        name: name,
        team: teamName,
        imageUrl: imageUrl,
      );

      if (teamPlayersMap.containsKey(teamName)) {
        teamPlayersMap[teamName]!.add(player);
      } else {
        teamPlayersMap[teamName] = [player];
      }
    }

    // Create team objects with their players
    final List<Team> teams = [];
    teamPlayersMap.forEach((teamName, players) {
      teams.add(Team(
        teamName: teamName,
        logo: _getTeamLogo(teamName),
        players: players,
      ));
    });

    return teams;
  }

  String _getTeamLogo(String teamName) {
    // Map team names to their logo file paths
    switch (teamName) {
      case 'Chennai Super Kings':
        return 'assets/logos/csk.png';
      case 'Mumbai Indians':
        return 'assets/logos/mi.png';
      case 'Royal Challengers Bengaluru':
        return 'assets/logos/rcb.png';
      case 'Kolkata Knight Riders':
        return 'assets/logos/kkr.png';
      case 'Delhi Capitals':
        return 'assets/logos/dc.png';
      case 'Punjab Kings':
        return 'assets/logos/pbks.png';
      case 'Rajasthan Royals':
        return 'assets/logos/rr.png';
      case 'Sunrisers Hyderabad':
        return 'assets/logos/srh.png';
      case 'Lucknow Super Giants':
        return 'assets/logos/lsg.png';
      case 'Gujarat Titans':
        return 'assets/logos/gt.png';
      default:
        return 'assets/logos/default.png';
    }
  }

  // Function to set image URLs for players when they are provided separately
  void updatePlayerImageUrls(List<Team> teams, Map<String, String> imageUrlMap) {
    for (var team in teams) {
      for (var i = 0; i < team.players.length; i++) {
        final player = team.players[i];
        if (imageUrlMap.containsKey(player.name)) {
          team.players[i] = Player(
            name: player.name,
            team: player.team,
            imageUrl: imageUrlMap[player.name]!,
          );
        }
      }
    }
  }
}