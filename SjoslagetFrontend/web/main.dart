import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:Sjoslaget/app_component.dart';
import 'package:Sjoslaget/client/client_factory.dart' show SJOSLAGET_API_ROOT;

void main() {
	// false for testing on local, true for production builds
	final release = false;

	List<dynamic> providers;
	if (release) {
		providers = <dynamic>[
			ROUTER_PROVIDERS,
			provide(APP_BASE_HREF, useValue: '/'),
			provide(SJOSLAGET_API_ROOT, useValue: 'https://sjoslaget.se/api'),
		];
	} else {
		providers = <dynamic>[
			ROUTER_PROVIDERS,
			provide(APP_BASE_HREF, useValue: '/'),
			provide(SJOSLAGET_API_ROOT, useValue: 'http://localhost:61796/api'),
			const Provider<dynamic>(LocationStrategy, useClass: HashLocationStrategy)
		];
	}

	bootstrap(AppComponent, providers);
}
