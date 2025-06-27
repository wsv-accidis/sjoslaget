import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'package:gotland_frontend/one_screen.dart';
import 'package:gotland_frontend/two_screen.dart';

void main() {
  // TODO: Verify that this works on IIS with existing/updated Web.Config
  usePathUrlStrategy();
  runApp(const MainApp());
}

// For docs, see https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
final _mainRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => OneScreen()),
    GoRoute(path: '/two', builder: (context, state) => TwoScreen()),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _mainRouter);
  }
}
