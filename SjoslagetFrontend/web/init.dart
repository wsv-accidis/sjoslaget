import 'package:angular/angular.dart' show Provider;
import 'package:angular_router/angular_router.dart';

class Init {
	static const String API_ROOT = 'https://sjoslaget.se/api';
	//static const String API_ROOT = 'http://localhost:61796/api';

	static const List<Provider<dynamic>> sjoslagetRouterProviders = routerProviders;
	//static const List<Provider<dynamic>> sjoslagetRouterProviders = routerProvidersHash;
}
