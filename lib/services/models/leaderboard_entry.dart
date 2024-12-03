import 'package:hive/hive.dart';

part 'leaderboard_entry.g.dart';

@HiveType(typeId: 0) // Unique typeId for this adapter
class LeaderboardEntry extends HiveObject {
  @HiveField(0)
  final String playerName;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final int score;

  LeaderboardEntry({
    required this.playerName,
    required this.category,
    required this.score,
  });
}
