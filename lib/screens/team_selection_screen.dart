import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      await Provider.of<SelectionProvider>(context, listen: false).loadSavedSelection();
      final hasData = Provider.of<SelectionProvider>(context, listen: false).hasLoadedSavedData;
      if (hasData) {
        await Provider.of<SelectionProvider>(context, listen: false).loadSavedData(_teams);
        if (mounted) _showSavedDataDialog();
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
        title: Text('Saved Selection', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('You have a saved team and player selection. Would you like to view it?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('No', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedSelectionScreen()),
              );
            },
            child: Text('Yes', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('IPL 2025 - Select Your Team', style: GoogleFonts.poppins(color:Colors.white,fontSize: 20, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blueGrey[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(Icons.history, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SavedSelectionScreen()),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _teams.length,
                itemBuilder: (ctx, index) => _buildTeamCard(_teams[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    final fullTeamName = _csvService.getFullTeamName(team.teamName);
    return GestureDetector(
      onTap: () {
        Provider.of<SelectionProvider>(context, listen: false).selectTeam(team);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlayerSelectionScreen()),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: [_getTeamColor(team.teamName).withOpacity(0.8), _getTeamColor(team.teamName)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                    ),
                  ),
                  child: Image.asset(
                    team.logo,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.sports_cricket,
                      size: 80,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
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
                fullTeamName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 200.ms),
    );
  }

  Color _getTeamColor(String teamName) {
    switch (teamName) {
      case 'CSK': return Colors.yellow.shade700;
      case 'MI': return Colors.blue.shade800;
      case 'RCB': return Colors.red.shade800;
      case 'KKR': return Colors.purple;
      case 'DC': return Colors.blue;
      case 'PBKS': return Colors.red;
      case 'RR': return Colors.pink;
      case 'SRH': return Colors.orange;
      case 'LSG': return Colors.blue.shade300;
      case 'GT': return Colors.teal;
      default: return Colors.blueGrey;
    }
  }
}