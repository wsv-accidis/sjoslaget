import 'package:angular/angular.dart' show Provider;
import 'package:angular_router/angular_router.dart';

class Init {
	//static const String API_ROOT = 'http://hemligtest.absolutgotland.se/api';
	static const String API_ROOT = 'http://localhost:49265/api';

	//static const List<Provider<dynamic>> gotlandRouterProviders = routerProviders;
	static const List<Provider<dynamic>> gotlandRouterProviders = routerProvidersHash;
}
