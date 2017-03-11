import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'content/about_component.dart';
import 'content/booking_page.dart';
import 'content/contact_page.dart';
import 'content/not_found_page.dart';
import 'content/pricing_page.dart';
import 'content/start_page.dart';
import 'client/client_factory.dart';
import 'client/cruise_repository.dart';
import 'client/session_storage_cache.dart';

@Component(
	selector: 'sjoslaget-app',
	styleUrls: const ['app_component.css'],
	templateUrl: 'app_component.html',
	providers: const [ClientFactory, CruiseRepository, SessionStorageCache],
	directives: const [ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/', name: 'Start', component: StartPage, useAsDefault: true),
	const Route(path: '/allt-om/...', name: 'About', component: AboutComponent),
	const Route(path: '/bokning', name: 'Booking', component: BookingPage),
	const Route(path: '/contact', name: 'Contact', component: ContactPage),
	const Route(path: '/priser', name: 'Pricing', component: PricingPage),
	const Route(path: '/**', name: 'NotFound', component: NotFoundPage)
])
class AppComponent {
}
