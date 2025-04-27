import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../services/local_storage_service.dart';

class SelectionProvider with ChangeNotifier {
  Team? _selectedTeam;
  final List<Player> _selectedPlayers = [];
  final LocalStorageService _storageService = LocalStorageService();
  bool _hasLoadedSavedData = false;

  Team? get selectedTeam => _selectedTeam;
  List<Player> get selectedPlayers => _selectedPlayers;
  bool get hasLoadedSavedData => _hasLoadedSavedData;

  void selectTeam(Team team) {
    _selectedTeam = team;
    _selectedPlayers.clear();
    notifyListeners();
  }

  void togglePlayerSelection(Player player) {
    final isSelected = _selectedPlayers.any((p) => p.name == player.name);

    if (isSelected) {
      _selectedPlayers.removeWhere((p) => p.name == player.name);
    } else {
      if (_selectedPlayers.length < 3) {
        _selectedPlayers.add(player);
      }
    }
    notifyListeners();
  }

  bool isPlayerSelected(Player player) {
    return _selectedPlayers.any((p) => p.name == player.name);
  }

  int get selectedPlayersCount => _selectedPlayers.length;

  bool canSaveSelection() {
    return _selectedTeam != null && _selectedPlayers.length == 3;
  }

  Future<void> saveSelection() async {
    if (canSaveSelection()) {
      await _storageService.saveTeam(_selectedTeam!.teamName);

      final playerNames = _selectedPlayers.map((p) => p.name).toList();
      await _storageService.savePlayers(playerNames);

      // Save player images too for future reference
      final playerImages = {
        for (var player in _selectedPlayers)
          player.name: player.imageUrl
      };
      await _storageService.savePlayerImages(playerImages);
    }
  }

  Future<void> loadSavedSelection() async {
    final savedTeamName = await _storageService.getSavedTeam();
    final savedPlayerNames = await _storageService.getSavedPlayers();

    _hasLoadedSavedData = savedTeamName != null && savedPlayerNames.isNotEmpty;
    notifyListeners();
  }

  Future<void> loadSavedData(List<Team> allTeams) async {
    final savedTeamName = await _storageService.getSavedTeam();
    final savedPlayerNames = await _storageService.getSavedPlayers();
    final savedPlayerImages = await _storageService.getSavedPlayerImages();

    if (savedTeamName != null && savedPlayerNames.isNotEmpty) {
      _selectedTeam = allTeams.firstWhere(
            (team) => team.teamName == savedTeamName,
        orElse: () => allTeams.first,
      );

      _selectedPlayers.clear();

      for (var playerName in savedPlayerNames) {
        for (var player in _selectedTeam!.players) {
          if (player.name == playerName) {
            // Use saved image URL if available
            final imageUrl = savedPlayerImages[playerName] ?? player.imageUrl;
            _selectedPlayers.add(
                Player(
                  name: player.name,
                  team: player.team,
                  imageUrl: imageUrl,
                )
            );
            break;
          }
        }
      }

      _hasLoadedSavedData = true;
    }

    notifyListeners();
  }

  void clearSelection() {
    _selectedTeam = null;
    _selectedPlayers.clear();
    _storageService.clearSavedData();
    notifyListeners();
  }
}