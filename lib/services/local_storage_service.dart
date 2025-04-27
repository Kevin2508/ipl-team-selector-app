import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _teamKey = 'selected_team';
  static const String _playersKey = 'selected_players';
  static const String _playerImagesKey = 'player_images';

  Future<void> saveTeam(String teamName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_teamKey, teamName);
  }

  Future<void> savePlayers(List<String> playerNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_playersKey, playerNames);
  }

  Future<void> savePlayerImages(Map<String, String> playerImages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(playerImages);
    await prefs.setString(_playerImagesKey, jsonStr);
  }

  Future<String?> getSavedTeam() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_teamKey);
  }

  Future<List<String>> getSavedPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_playersKey) ?? [];
  }

  Future<Map<String, String>> getSavedPlayerImages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_playerImagesKey);
    if (jsonStr == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  Future<void> clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_teamKey);
    await prefs.remove(_playersKey);
    await prefs.remove(_playerImagesKey);
  }
}