import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/platform/common.dart';

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
			provide(SJOSLAGET_API_ROOT, useValue: 'http://localhost:60949/api'),
			const Provider(LocationStrategy, useClass: HashLocationStrategy)
		];
	}

	bootstrap(AppComponent, providers);
}
