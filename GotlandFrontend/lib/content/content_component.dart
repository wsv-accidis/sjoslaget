import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'start_page.dart';

@Component(
	selector: 'content-component',
	styleUrls: const ['content_component.css'],
	templateUrl: 'content_component.html',
	directives: const <dynamic>[ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/', name: 'Start', component: StartPage, useAsDefault: true),
//	const Route(path: '/allt-om/...', name: 'About', component: AboutComponent),
//	const Route(path: '/bokning', name: 'Booking', component: BookingPage),
//	const Route(path: '/kontakt', name: 'Contact', component: ContactPage),
//	const Route(path: '/priser', name: 'Pricing', component: PricingPage),
//	const Route(path: '/**', name: 'NotFound', component: NotFoundPage)
])
class ContentComponent {
}
