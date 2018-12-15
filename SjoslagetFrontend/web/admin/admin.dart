import 'package:Sjoslaget/admin/admin_component.template.dart';
import 'package:Sjoslaget/client/client_factory.dart' show SJOSLAGET_API_ROOT;
import 'package:angular/angular.dart';

import '../init.dart';
import 'admin.template.dart' as self;

@GenerateInjector([
	ValueProvider<String>.forToken(SJOSLAGET_API_ROOT, Init.API_ROOT)
])
const InjectorFactory injectorFactory = self.injectorFactory$Injector;

void main() {
	runApp(AdminComponentNgFactory, createInjector: injectorFactory);
}
