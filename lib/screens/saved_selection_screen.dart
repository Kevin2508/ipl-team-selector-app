import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/selection_provider.dart';
import '../services/csv_service.dart';
import 'team_selection_screen.dart';

class SavedSelectionScreen extends StatelessWidget {
  const SavedSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final csvService = CsvService();
    return Consumer<SelectionProvider>(
      builder: (ctx, provider, _) {
        final selectedTeam = provider.selectedTeam;
        final selectedPlayers = provider.selectedPlayers;
        if (selectedTeam == null || selectedPlayers.isEmpty) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey[900]!, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_cricket, size: 80, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(height: 16),
                    Text(
                      'No saved selection found',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final fullTeamName = csvService.getFullTeamName(selectedTeam.teamName);
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
                  title: Text('Your Selection', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.transparent,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_getTeamColor(selectedTeam.teamName), Colors.blueGrey[800]!],
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
                          color: Colors.red.withOpacity(0.8),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onPressed: () => _showDeleteConfirmation(context, provider),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_getTeamColor(selectedTeam.teamName).withOpacity(0.8), _getTeamColor(selectedTeam.teamName)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Selected Team',
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    selectedTeam.logo,
                                    height: 80,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.sports_cricket,
                                      size: 80,
                                      color: _getTeamColor(selectedTeam.teamName),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  fullTeamName,
                                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Selected Players',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (ctx, index) {
                        final player = selectedPlayers[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: CachedNetworkImage(
                                    imageUrl: player.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: _getTeamColor(selectedTeam.teamName),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_getTeamColor(selectedTeam.teamName), _getTeamColor(selectedTeam.teamName).withOpacity(0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                child: Text(
                                  player.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(duration: 200.ms);
                      },
                      childCount: selectedPlayers.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const TeamSelectionScreen()),
                              (route) => false,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_getTeamColor(selectedTeam.teamName), _getTeamColor(selectedTeam.teamName).withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Select Another Team',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ).animate().scale(duration: 200.ms),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, SelectionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Selection', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete your saved selection?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              provider.clearSelection();
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const TeamSelectionScreen()),
                    (route) => false,
              );
            },
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ).animate().slideY(begin: 0.2, duration: 300.ms),
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