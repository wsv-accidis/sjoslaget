import 'package:get_it/get_it.dart' show GetIt;
import 'package:gotland_frontend/data/article/article_repository.dart';
import 'package:gotland_frontend/data/article/search_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final serviceLocator = GetIt.instance;

// See: https://pub.dev/packages/get_it
void initServiceLocator() {
  serviceLocator.registerSingleton(ArticleRepository());
    serviceLocator.registerSingletonAsync(
    () => SharedPreferencesWithCache.create(cacheOptions: SharedPreferencesWithCacheOptions()),
  );
  serviceLocator.registerSingletonWithDependencies(
    () => SearchService(serviceLocator<ArticleRepository>(), serviceLocator<SharedPreferencesWithCache>()),
    dependsOn: [SharedPreferencesWithCache],
  );
}
