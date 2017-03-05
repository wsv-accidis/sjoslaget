import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'client/client_factory.dart';
import 'client/cruise_repository.dart';
import 'content_pages/content_pages.dart';
import 'login_page/login_page.dart';

@Component(
	selector: 'sjoslaget-app',
	styleUrls: const ['app_component.css'],
	templateUrl: 'app_component.html',
	providers: const [ClientFactory, CruiseRepository],
	directives: const [ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/', name: 'Start', component: StartPage, useAsDefault: true),
	const Route(path: '/sjoslaget', name: 'About', component: AboutPage),
	const Route(path: '/priser', name: 'Pricing', component: PricingPage),
	const Route(path: '/bokning', name: 'Booking', component: LoginPage),
	const Route(path: '/historik', name: 'History', component: HistoryPage)
])
class AppComponent {
}
