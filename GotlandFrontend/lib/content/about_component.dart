import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'about_booking_page.template.dart';
import 'about_faq_page.template.dart';
import 'about_history_page.template.dart';
import 'about_privacy_page.template.dart';
import 'about_program_page.template.dart';
import 'about_routes.dart';
import 'about_rules_page.template.dart';
import 'about_start_page.template.dart';

@Component(
	selector: 'about-page',
	styleUrls: ['content_styles.css'],
	template: '''
	<router-outlet [routes]="routes"></router-outlet>
	''',
	directives: <dynamic>[routerDirectives]
)
class AboutComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: AboutRoutes.start, component: AboutStartPageNgFactory),
		RouteDefinition(routePath: AboutRoutes.booking, component: AboutBookingPageNgFactory),
		RouteDefinition(routePath: AboutRoutes.faq, component: AboutFaqPageNgFactory),
		RouteDefinition(routePath: AboutRoutes.history, component: AboutHistoryPageNgFactory),
		RouteDefinition(routePath: AboutRoutes.program, component: AboutProgramPageNgFactory),
		RouteDefinition(routePath: AboutRoutes.rules, component: AboutRulesPageNgFactory),
		RouteDefinition(routePath: AboutRoutes.privacy, component: AboutPrivacyPageNgFactory),
	];
}
