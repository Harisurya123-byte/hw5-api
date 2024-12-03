import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/leaderboard_entry.dart'; // Ensure the correct path to your model file.

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Open the Hive box for leaderboard entries.
    final leaderboardBox = Hive.box<LeaderboardEntry>('leaderboard');

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ValueListenableBuilder(
        valueListenable: leaderboardBox.listenable(),
        builder: (context, Box<LeaderboardEntry> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No scores yet!"));
          }

          // Retrieve and sort entries by score in descending order.
          final entries = box.values.toList()
            ..sort((a, b) => b.score.compareTo(a.score));

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                title: Text("${entry.playerName} - ${entry.category}"),
                trailing: Text("Score: ${entry.score}"),
              );
            },
          );
        },
      ),
    );
  }
}
