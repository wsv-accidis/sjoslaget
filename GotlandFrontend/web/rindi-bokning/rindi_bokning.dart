import 'package:Gotland/client/client_factory.dart' show GOTLAND_API_ROOT;
import 'package:Gotland/external/external_component.template.dart';
import 'package:angular/angular.dart';

import '../init.dart';
import 'rindi_bokning.template.dart' as self;

@GenerateInjector([
	ValueProvider<String>.forToken(GOTLAND_API_ROOT, Init.API_ROOT),
	Init.gotlandRouterProviders
])
const InjectorFactory injectorFactory = self.injectorFactory$Injector;

void main() {
	runApp(ExternalComponentNgFactory, createInjector: injectorFactory);
}
