import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

import 'about_booking_page.dart';
import 'about_faq_page.dart';
import 'about_history_page.dart';
import 'about_program_page.dart';
import 'about_routes.dart';
import 'about_rules_page.dart';
import 'content_routes.dart';

@Component(
	selector: 'about-start-page',
	styleUrls: ['content_styles.css'],
	templateUrl: 'about_start_page_sj.html',
	directives: <dynamic>[routerDirectives, MaterialIconComponent, AboutBookingPage, AboutFaqPage, AboutHistoryPage, AboutProgramPage, AboutRulesPage],
	exports: [AboutRoutes, ContentRoutes]
)
class AboutStartPage {
}
