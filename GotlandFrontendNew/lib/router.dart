import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotland_frontend/ui/app_scaffold.dart';

import 'ui/article/article_page.dart';
import 'ui/start/start_page.dart';

final _routerKey = GlobalKey<NavigatorState>();

// See: https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _routerKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, route, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (context, state) => StartPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/article',
              builder: (context, state) => ArticlePage(articleId: ''),
            ),
            GoRoute(
              path: '/article/:articleId',
              builder: (context, state) => ArticlePage(articleId: state.pathParameters['articleId']!),
            ),
          ],
        ),
      ],
    ),
  ],
);
