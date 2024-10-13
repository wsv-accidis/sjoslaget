import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:world/game/menu_overlay_assets.dart';

class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key});

  static const overlayKey = "menu";

  @override
  State<StatefulWidget> createState() {
    return MenuOverlayState();
  }
}

class MenuOverlayState extends State<MenuOverlay> {
  var _visible = true;

  bool get visible {
    return _visible;
  }

  set visible(bool value) {
    if (value == _visible) return;
    setState(() {
      _visible = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 1.0,
        child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
                color: Colors.black,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: NineTileBoxWidget(
                    image: MenuOverlayAssets.frame,
                    tileSize: 64,
                    destTileSize: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                    child: IgnorePointer(
                        ignoring: !_visible,
                        child: Row(children: [
                          OutlinedButton(onPressed: onPressed, child: const Text("This is a button")),
                          const Text(style: TextStyle(color: Colors.white, decoration: TextDecoration.none), textAlign: TextAlign.center, "Hello, World")
                        ]))))));
  }

  void onPressed() {
    print("Got clicked");
  }
}
