import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:Sjoslaget/client/client_factory.dart' show SJOSLAGET_API_ROOT;

class Init {
	// false for testing on local, true for production builds
	static final release = false;

	static List<dynamic> getProviders(String baseHref) {
		if (release) {
			return <dynamic>[
				ROUTER_PROVIDERS,
				provide(APP_BASE_HREF, useValue: baseHref),
				provide(SJOSLAGET_API_ROOT, useValue: 'https://sjoslaget.se/api'),
			];
		} else {
			return <dynamic>[
				ROUTER_PROVIDERS,
				provide(APP_BASE_HREF, useValue: '/'),
				provide(SJOSLAGET_API_ROOT, useValue: 'http://localhost:61796/api'),
				const Provider<dynamic>(LocationStrategy, useClass: HashLocationStrategy)
			];
		}
	}
}
