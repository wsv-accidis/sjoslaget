import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'login_page/login_page.dart';
import 'content_pages/start_page.dart';

@Component(
  selector: 'sjoslaget-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [ROUTER_DIRECTIVES]
)
@RouteConfig(const [
  const Route(path: '/', name: 'Start', component: StartPage, useAsDefault: true),
  const Route(path: '/login', name: 'LogIn', component: LoginPage)
])
class AppComponent {
}
