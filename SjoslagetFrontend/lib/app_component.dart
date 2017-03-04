import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import 'login_page/login_page.dart';
import 'start_page/start_page.dart';

@Component(
  selector: 'sjoslaget-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [ROUTER_DIRECTIVES, materialDirectives, StartPage, LoginPage],
  providers: const [materialProviders],
)
@RouteConfig(const [
  const Route(path: '/', name: 'Start', component: StartPage, useAsDefault: true),
  const Route(path: '/login', name: 'LogIn', component: LoginPage)
])
class AppComponent {
}
