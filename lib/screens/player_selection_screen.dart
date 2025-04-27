import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/team.dart';
import '../providers/selection_provider.dart';
import '../services/csv_service.dart';
import 'saved_selection_screen.dart';

class PlayerSelectionScreen extends StatelessWidget {
  const PlayerSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final csvService = CsvService();
    return Consumer<SelectionProvider>(
      builder: (ctx, provider, _) {
        final team = provider.selectedTeam;
        if (team == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return const SizedBox.shrink();
        }
        final fullTeamName = csvService.getFullTeamName(team.teamName);
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
                  title: Text('Select Players from $fullTeamName', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.transparent,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_getTeamColor(team.teamName), Colors.blueGrey[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getTeamColor(team.teamName).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected: ${provider.selectedPlayersCount}/3',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: provider.selectedPlayersCount == 3
                              ? () async {
                            await provider.saveSelection();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SavedSelectionScreen()),
                              );
                            }
                          }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: provider.selectedPlayersCount == 3
                                    ? [_getTeamColor(team.teamName), _getTeamColor(team.teamName).withOpacity(0.7)]
                                    : [Colors.grey, Colors.grey.shade700],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Save Selection',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (ctx, index) {
                        final player = team.players[index];
                        final isSelected = provider.isPlayerSelected(player);
                        return _buildPlayerCard(context, player, isSelected, provider, team);
                      },
                      childCount: team.players.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerCard(BuildContext context, Player player, bool isSelected, SelectionProvider provider, Team team) {
    return GestureDetector(
      onTap: () {
        if (!isSelected && provider.selectedPlayersCount >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only select 3 players', style: GoogleFonts.poppins()),
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }
        provider.togglePlayerSelection(player);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected ? _getTeamColor(team.teamName).withOpacity(0.4) : Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          color: isSelected ? _getTeamColor(team.teamName).withOpacity(0.2) : Colors.white.withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: player.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: _getTeamColor(team.teamName),
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ).animate().scale(duration: 200.ms),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_getTeamColor(team.teamName), _getTeamColor(team.teamName).withOpacity(0.7)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Text(
                player.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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