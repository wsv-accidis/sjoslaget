import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:world/game/the_player.dart';

class WorldGame extends StatefulWidget {
  const WorldGame({super.key, required this.title});

  final String title;

  @override
  State<WorldGame> createState() => _WorldGameState();
}

class _WorldGameState extends State<WorldGame> {
  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
        backgroundColor: const Color.fromRGBO(21, 108, 153, 1.0),
        playerControllers: [
          Keyboard(
              config: KeyboardConfig(
            acceptedKeys: [],
            directionalKeys: [KeyboardDirectionalKeys.arrows()],
          )),
        ],
        map: WorldMapByTiled(WorldMapReader.fromAsset('tiled/map-main.json')),
        player: ThePlayer(Vector2(300, 300)),
        showCollisionArea: false);
  }
}
