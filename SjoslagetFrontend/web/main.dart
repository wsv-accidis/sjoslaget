import 'package:angular/angular.dart';

import 'package:Sjoslaget/app_component.dart';

import 'init.dart';

void main() {
	bootstrap(AppComponent, Init.getProviders('/'));
}
