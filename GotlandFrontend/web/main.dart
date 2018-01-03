import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:Gotland/app_component.dart';
import 'package:Gotland/client/client_factory.dart' show GOTLAND_API_ROOT;

void main() {
	// false for testing on local, true for production builds
	final release = false;

	List<dynamic> providers;
	if (release) {
		providers = <dynamic>[
			ROUTER_PROVIDERS,
			provide(APP_BASE_HREF, useValue: '/'),
			provide(GOTLAND_API_ROOT, useValue: 'http://ag-test.sjoslaget.se/api'),
		];
	} else {
		providers = <dynamic>[
			ROUTER_PROVIDERS,
			provide(APP_BASE_HREF, useValue: '/'),
			provide(GOTLAND_API_ROOT, useValue: 'http://localhost:49265/api'),
			const Provider<dynamic>(LocationStrategy, useClass: HashLocationStrategy)
		];
	}

	bootstrap(AppComponent, providers);
}
