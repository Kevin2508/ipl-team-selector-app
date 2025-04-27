import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/team.dart';
import '../providers/selection_provider.dart';
import 'saved_selection_screen.dart';

class PlayerSelectionScreen extends StatelessWidget {
  const PlayerSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionProvider>(
      builder: (ctx, provider, _) {
        final team = provider.selectedTeam;

        if (team == null) {
          // Redirect back if no team is selected
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Select Players from ${team.teamName}'),
            backgroundColor: _getTeamColor(team.teamName),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: _getTeamColor(team.teamName).withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected: ${provider.selectedPlayersCount}/3',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: provider.selectedPlayersCount == 3
                          ? () async {
                        await provider.saveSelection();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedSelectionScreen(),
                            ),
                          );
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getTeamColor(team.teamName),
                      ),
                      child: const Text('Save Selection'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: team.players.length,
                  itemBuilder: (ctx, index) {
                    final player = team.players[index];
                    final isSelected = provider.isPlayerSelected(player);

                    return _buildPlayerCard(context, player, isSelected, provider, team);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerCard(BuildContext context, Player player, bool isSelected,
      SelectionProvider provider, Team team) {
    return GestureDetector(
      onTap: () {
        // Only allow selection if not already at 3 players
        if (!isSelected && provider.selectedPlayersCount >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only select 3 players'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
        provider.togglePlayerSelection(player);
      },
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isSelected ? _getTeamColor(team.teamName).withOpacity(0.2) : null,
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
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                player.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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