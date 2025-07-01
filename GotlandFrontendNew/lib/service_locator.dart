import 'package:get_it/get_it.dart' show GetIt;

import 'data/article/article_repository.dart';

final serviceLocator = GetIt.instance;

// See: https://pub.dev/packages/get_it
void initServiceLocator() {
  serviceLocator.registerSingleton(ArticleRepository());
}
