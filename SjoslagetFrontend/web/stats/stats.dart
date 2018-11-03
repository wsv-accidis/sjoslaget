import 'package:Sjoslaget/admin/stats_component.template.dart';
import 'package:Sjoslaget/client/client_factory.dart' show SJOSLAGET_API_ROOT;
import 'package:angular/angular.dart';

import '../init.dart';
import 'stats.template.dart' as self;

@GenerateInjector([
	ValueProvider.forToken<String>(SJOSLAGET_API_ROOT, Init.API_ROOT)
])
const InjectorFactory injectorFactory = self.injectorFactory$Injector;

void main() {
	runApp(StatsComponentNgFactory, createInjector: injectorFactory);
}
