import 'package:gotland/app_component.template.dart';
import 'package:gotland/client/client_factory.dart' show GOTLAND_API_ROOT;
import 'package:angular/angular.dart';

import 'init.dart';
import 'main.template.dart' as self;

@GenerateInjector([
	ValueProvider<String>.forToken(GOTLAND_API_ROOT, Init.API_ROOT),
	Init.gotlandRouterProviders
])
const InjectorFactory injectorFactory = self.injectorFactory$Injector;

void main() {
	runApp(AppComponentNgFactory, createInjector: injectorFactory);
}