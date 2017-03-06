import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/platform/common.dart';

import 'package:Sjoslaget/app_component.dart';
import 'package:Sjoslaget/client/client_factory.dart' show SJOSLAGET_API_ROOT;

void main() {
	bootstrap(AppComponent, [
		ROUTER_PROVIDERS,
		provide(APP_BASE_HREF, useValue: '/'),
		provide(SJOSLAGET_API_ROOT, useValue: 'https://test.sjoslaget.se/api'),
//		const Provider(LocationStrategy, useClass: HashLocationStrategy)
	]);
}
