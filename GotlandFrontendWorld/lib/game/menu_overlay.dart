import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:world/game/menu_overlay_assets.dart';
import 'package:world/widget/basic_markdown.dart';

enum MenuMode {
  // Only show home button in top left corner
  homeOnly,

  // Menu row with buttons on top of screen
  collapsed,

  // Full screen overlay with content
  expanded
}

class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key, required this.game});

  static const overlayKey = 'menu';

  final BonfireGame game;

  @override
  State<StatefulWidget> createState() {
    return MenuOverlayState();
  }
}

class MenuOverlayState extends State<MenuOverlay> {
  var _mode = MenuMode.collapsed;

  MenuMode get mode {
    return _mode;
  }

  set mode(MenuMode value) {
    if (value == _mode) return;

    // Pause the game while the overlay covers the entire screen
    if (value == MenuMode.expanded) {
      widget.game.pauseEngine();
    } else {
      widget.game.resumeEngine();
    }

    setState(() {
      _mode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: switch (_mode) {
          MenuMode.collapsed || MenuMode.expanded => buildMenu(context),
          MenuMode.homeOnly => buildHomeButton()
        });
  }

  Widget buildHomeButton() {
    return Container(
        color: Colors.black,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: OutlinedButton(onPressed: onPressed, child: const Text("Home")));
  }

  Widget buildMenu(BuildContext context) {
    const collapsedHeight = 120.0;
    const outerVertInset = 16.0;
    const innerVertInset = 8.0;
    const outerHorzInset = 16.0;
    const innerHorzInset = 20.0;

    final screenSize = MediaQuery.of(context).size;
    final expandedHeight = max(collapsedHeight, screenSize.height);
    const menuRowHeight = collapsedHeight - 2 * outerVertInset - 2 * innerVertInset;

    return TweenAnimationBuilder<double>(
        tween:
            Tween<double>(begin: collapsedHeight, end: _mode == MenuMode.expanded ? expandedHeight : collapsedHeight),
        duration: const Duration(milliseconds: 300),
        builder: (BuildContext context, double height, Widget? child) {
          final isExpanding = height > collapsedHeight;
          return SizedBox(
              height: height,
              child: Container(
                  decoration: const BoxDecoration(color: Colors.black),
                  margin: const EdgeInsets.symmetric(horizontal: outerHorzInset, vertical: outerVertInset),
                  child: NineTileBoxWidget(
                      image: MenuOverlayAssets.frame,
                      tileSize: 32,
                      destTileSize: 32,
                      padding: const EdgeInsets.symmetric(horizontal: innerHorzInset, vertical: innerVertInset),
                      child: buildMenuContents(menuRowHeight, isExpanding))));
        });
  }

  Widget buildMenuContents(double menuRowHeight, bool isExpanding) {
    final List<Widget> children = [
      SizedBox(
          height: menuRowHeight,
          child: Row(children: [
            OutlinedButton(onPressed: onPressed, child: const Text("This is a button")),
            const Text(
                style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
                textAlign: TextAlign.center,
                "Hello, World")
          ]))
    ];

    if (isExpanding) {
      children.add(const Expanded(child: Padding(padding: EdgeInsets.only(bottom: 8), child: BasicMarkdown(text: """
# Hello, world!

This is me writing some wicked Markdown.

Testing, testing.

Testing, testing.

Testing, testing.

Testing, testing.

Testing, testing.

Testing, testing.

Testing, testing.

Testing, testing.

Testing, testing.
"""))));
    }

    return Column(children: children, crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  void onPressed() {
    mode = switch (mode) {
      MenuMode.homeOnly => MenuMode.expanded,
      MenuMode.collapsed => MenuMode.expanded,
      MenuMode.expanded => MenuMode.collapsed
    };
  }
}
