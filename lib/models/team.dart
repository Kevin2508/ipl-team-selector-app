class Team {
  final String teamName;
  final String logo;
  final List<Player> players;

  Team({
    required this.teamName,
    required this.logo,
    required this.players,
  });
}

class Player {
  final String name;
  final String team;
  final String imageUrl;

  Player({
    required this.name,
    required this.team,
    required this.imageUrl,
  });
}