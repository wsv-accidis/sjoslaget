import 'package:go_router/go_router.dart';

import 'ui/start/start_page.dart';
import 'ui/article/article_page.dart';

// See: https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => StartPage()),
    GoRoute(path: '/article/:articleId', builder: (context, state) => ArticlePage(articleId: state.pathParameters['articleId']!)),
  ],
);
