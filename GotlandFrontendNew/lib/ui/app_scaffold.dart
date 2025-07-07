import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    if (_isWeb() || _isNarrowScreen(context)) {
      return Scaffold(bottomNavigationBar: navigationBar(context), body: navigationShell);
    } else {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 120.0),
          child: Container(
            margin: EdgeInsetsGeometry.fromLTRB(200.0, 20.0, 20.0, 20.0),
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: navigationBar(context),
          ),
        ),
        body: navigationShell,
      );
    }
  }

  NavigationBar navigationBar(BuildContext context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: "Start"),
        NavigationDestination(icon: Icon(Icons.ac_unit), label: "Allt om AG"),
        NavigationDestination(icon: Icon(Icons.ac_unit), label: "Program"),
        NavigationDestination(icon: Icon(Icons.ac_unit), label: "Bokning"),
      ],
      onDestinationSelected: (index) => navigationShell.goBranch(index, initialLocation: true),
      selectedIndex: navigationShell.currentIndex,
    );
  }

  bool _isNarrowScreen(BuildContext context) => MediaQuery.sizeOf(context).width < 600.0;

  bool _isWeb() =>
      kIsWeb && (TargetPlatform.iOS == defaultTargetPlatform || TargetPlatform.android == defaultTargetPlatform);
}
