import 'package:angular/angular.dart';

import 'package:Sjoslaget/admin/admin_component.dart';

import '../init.dart';

void main() {
	bootstrap(AdminComponent, Init.getProviders('/admin'));
}
