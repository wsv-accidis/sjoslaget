import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'about_component.dart';
import 'booking_page.dart';
import 'contact_page.dart';
import 'not_found_page.dart';
import 'pricing_page.dart';
import 'start_page.dart';

@Component(
	selector: 'content-component',
	styleUrls: const ['content_component.css'],
	templateUrl: 'content_component.html',
	directives: const <dynamic>[ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/', name: 'Start', component: StartPage, useAsDefault: true),
	const Route(path: '/allt-om/...', name: 'About', component: AboutComponent),
	const Route(path: '/bokning', name: 'Booking', component: BookingPage),
	const Route(path: '/contact', name: 'Contact', component: ContactPage),
	const Route(path: '/priser', name: 'Pricing', component: PricingPage),
	const Route(path: '/**', name: 'NotFound', component: NotFoundPage)
])
class ContentComponent {
}
