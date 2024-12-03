import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/models/leaderboard_entry.dart';
import 'screens/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(LeaderboardEntryAdapter()); // Registers the adapter
  await Hive.openBox<LeaderboardEntry>('leaderboard'); // Opens the Hive box
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SetupScreen(),
    );
  }
}
