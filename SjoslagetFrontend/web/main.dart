import 'package:Sjoslaget/app_component.template.dart';
import 'package:Sjoslaget/client/client_factory.dart' show SJOSLAGET_API_ROOT;
import 'package:angular/angular.dart';

import 'init.dart';
import 'main.template.dart' as self;

@GenerateInjector([
	ValueProvider.forToken<String>(SJOSLAGET_API_ROOT, Init.API_ROOT)
])
const InjectorFactory injectorFactory = self.injectorFactory$Injector;

void main() {
	runApp(AppComponentNgFactory, createInjector: injectorFactory);
}
