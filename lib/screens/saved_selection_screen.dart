import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            appBar: AppBar(
              title: const Text('Your Selection'),
            ),
            body: const Center(
              child: Text(
                'No saved selection found',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        // Get full team name from abbreviation
        final fullTeamName = csvService.getFullTeamName(selectedTeam.teamName);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Selection'),
            backgroundColor: _getTeamColor(selectedTeam.teamName),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _showDeleteConfirmation(context, provider);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Selected Team',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              selectedTeam.logo,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.sports_cricket,
                                  size: 60,
                                  color: _getTeamColor(selectedTeam.teamName),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            Text(
                              fullTeamName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selected Players',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: selectedPlayers.length,
                  itemBuilder: (ctx, index) {
                    final player = selectedPlayers[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: player.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
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
                              color: _getTeamColor(selectedTeam.teamName).withOpacity(0.8),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              player.name,
                              style: const TextStyle(
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
                    );
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const TeamSelectionScreen(),
                        ),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getTeamColor(selectedTeam.teamName),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Select Another Team',
                      style: TextStyle(fontSize: 16),
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

  void _showDeleteConfirmation(BuildContext context, SelectionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selection'),
        content: const Text('Are you sure you want to delete your saved selection?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearSelection();
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const TeamSelectionScreen(),
                ),
                    (route) => false,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getTeamColor(String teamName) {
    switch (teamName) {
      case 'CSK':
        return Colors.yellow.shade700;
      case 'MI':
        return Colors.blue.shade800;
      case 'RCB':
        return Colors.red.shade800;
      case 'KKR':
        return Colors.purple;
      case 'DC':
        return Colors.blue;
      case 'PBKS':
        return Colors.red;
      case 'RR':
        return Colors.pink;
      case 'SRH':
        return Colors.orange;
      case 'LSG':
        return Colors.blue.shade300;
      case 'GT':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }
}