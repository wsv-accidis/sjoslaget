import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:gotland_frontend/router.dart';
import 'package:gotland_frontend/service_locator.dart';
import 'package:gotland_frontend/ui/gotland_theme.dart';

void main() {
  initServiceLocator();
  // TODO: Verify that this works on IIS with existing/updated Web.Config
  usePathUrlStrategy();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router, theme: GotlandTheme.lightThemeData(context));
  }
}
