import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'about_booking_page.dart';
import 'about_faq_page.dart';
import 'about_history_page.dart';
import 'about_program_page.dart';
import 'about_rules_page.dart';
import 'about_start_page.dart';

@Component(
	selector: 'about-page',
	styleUrls: const ['content_styles.css'],
	template: '''
	<router-outlet></router-outlet>
	''',
	directives: const [ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/sjoslaget', name: 'Start', component: AboutStartPage, useAsDefault: true),
	const Route(path: '/bokning', name: 'Booking', component: AboutBookingPage),
	const Route(path: '/vanliga-fragor', name: 'Faq', component: AboutFaqPage),
	const Route(path: '/historik', name: 'History', component: AboutHistoryPage),
	const Route(path: '/program', name: 'Program', component: AboutProgramPage),
	const Route(path: '/regler-ombord', name: 'Rules', component: AboutRulesPage)
])
class AboutComponent {
}
