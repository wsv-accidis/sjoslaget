import 'package:flutter/material.dart';
import 'package:world/game/menu_overlay_assets.dart';
import 'package:world/game/the_player_assets.dart';
import 'package:world/game/world_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-cache assets
  await MenuOverlayAssets.load();
  await ThePlayerAssets.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const WorldGame(title: 'World Game'),
    );
  }
}
