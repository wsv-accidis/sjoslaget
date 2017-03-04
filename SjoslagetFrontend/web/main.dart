import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/platform/common.dart';

import 'package:Sjoslaget/app_component.dart';

void main() {
	bootstrap(AppComponent, [
		ROUTER_PROVIDERS,
		provide(APP_BASE_HREF, useValue: '/'),
		//const Provider(LocationStrategy, useClass: HashLocationStrategy)
	]);
}
