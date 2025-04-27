import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/team.dart';

class CsvService {
  Future<List<Team>> loadTeamsFromCsv() async {
    final rawData = await rootBundle.loadString('assets/ipldata.csv');
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);

    // Assuming first row is header: [Name, Team, imageUrl]
    final rows = csvTable.sublist(1);

    // Create a map to group players by team
    final Map<String, List<Player>> teamPlayersMap = {};

    for (var row in rows) {
      if (row.length < 3) continue; // Skip invalid rows

      final name = row[0].toString();
      final teamName = row[1].toString();
      final imageUrl = row[2].toString();

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
    // Since your CSV appears to have abbreviated team names
    switch (teamName) {
      case 'CSK':
        return 'assets/logos/csk.jpg';
      case 'MI':
        return 'assets/logos/mi.jpg';
      case 'RCB':
        return 'assets/logos/rcb.jpg';
      case 'KKR':
        return 'assets/logos/kkr.jpg';
      case 'DC':
        return 'assets/logos/dc.jpg';
      case 'PBKS':
        return 'assets/logos/pbks.jpg';
      case 'RR':
        return 'assets/logos/rr.jpg';
      case 'SRH':
        return 'assets/logos/srh.jpg';
      case 'LSG':
        return 'assets/logos/lsg.jpg';
      case 'GT':
        return 'assets/logos/gt.jpg';
      default:
        return 'assets/logos/default.png';
    }
  }

  // Function to get full team name from abbreviation
  String getFullTeamName(String abbreviation) {
    switch (abbreviation) {
      case 'CSK':
        return 'Chennai Super Kings';
      case 'MI':
        return 'Mumbai Indians';
      case 'RCB':
        return 'Royal Challengers Bengaluru';
      case 'KKR':
        return 'Kolkata Knight Riders';
      case 'DC':
        return 'Delhi Capitals';
      case 'PBKS':
        return 'Punjab Kings';
      case 'RR':
        return 'Rajasthan Royals';
      case 'SRH':
        return 'Sunrisers Hyderabad';
      case 'LSG':
        return 'Lucknow Super Giants';
      case 'GT':
        return 'Gujarat Titans';
      default:
        return abbreviation;
    }
  }
}