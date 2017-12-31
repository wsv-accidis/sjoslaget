import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:frontend_shared/util.dart';

import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/event.dart';

@Component(
	selector: 'countdown-page',
	styleUrls: const ['content_styles.css', 'countdown_page.css'],
	templateUrl: 'countdown_page.html',
	directives: const <dynamic>[CORE_DIRECTIVES, formDirectives, materialDirectives],
	providers: const <dynamic>[materialProviders]
)
class CountdownPage implements OnInit {
	Future<Null> ngOnInit() async {

	}
}
