import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../providers/selection_provider.dart';
import '../services/csv_service.dart';
import 'player_selection_screen.dart';
import 'saved_selection_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  List<Team> _teams = [];
  bool _isLoading = true;
  final CsvService _csvService = CsvService();

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await _csvService.loadTeamsFromCsv();

      setState(() {
        _teams = teams;
        _isLoading = false;
      });

      // Check for saved selections
      await Provider.of<SelectionProvider>(context, listen: false).loadSavedSelection();
      final hasData = Provider.of<SelectionProvider>(context, listen: false).hasLoadedSavedData;

      if (hasData) {
        await Provider.of<SelectionProvider>(context, listen: false).loadSavedData(_teams);

        // Show dialog asking if user wants to view saved selection
        if (mounted) {
          _showSavedDataDialog();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading teams: $e')),
        );
      }
    }
  }

  void _showSavedDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Saved Selection'),
        content: const Text('You have a saved team and player selection. Would you like to view it?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedSelectionScreen(),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPL 2025 - Select Your Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _teams.length,
        itemBuilder: (ctx, index) {
          final team = _teams[index];
          return _buildTeamCard(team);
        },
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return GestureDetector(
      onTap: () {
        Provider.of<SelectionProvider>(context, listen: false).selectTeam(team);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlayerSelectionScreen(),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  team.logo,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.sports_cricket,
                      size: 80,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _getTeamColor(team.teamName),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                team.teamName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTeamColor(String teamName) {
    switch (teamName) {
      case 'Chennai Super Kings':
        return Colors.yellow.shade700;
      case 'Mumbai Indians':
        return Colors.blue.shade800;
      case 'Royal Challengers Bengaluru':
        return Colors.red.shade800;
      case 'Kolkata Knight Riders':
        return Colors.purple;
      case 'Delhi Capitals':
        return Colors.blue;
      case 'Punjab Kings':
        return Colors.red;
      case 'Rajasthan Royals':
        return Colors.pink;
      case 'Sunrisers Hyderabad':
        return Colors.orange;
      case 'Lucknow Super Giants':
        return Colors.blue.shade300;
      case 'Gujarat Titans':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }
}