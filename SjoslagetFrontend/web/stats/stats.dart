import 'package:angular/angular.dart';

import 'package:Sjoslaget/admin/stats_component.dart';

import '../init.dart';

void main() {
	bootstrap(StatsComponent, Init.getProviders('/stats'));
}
