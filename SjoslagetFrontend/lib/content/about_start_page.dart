import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import 'about_booking_page.dart';
import 'about_faq_page.dart';
import 'about_history_page.dart';
import 'about_program_page.dart';
import 'about_rules_page.dart';

@Component(
	selector: 'about-start-page',
	styleUrls: const ['content_styles.css'],
	templateUrl: 'about_start_page.html',
	directives: const [
		materialDirectives,
		ROUTER_DIRECTIVES,
		AboutBookingPage,
		AboutFaqPage,
		AboutHistoryPage,
		AboutProgramPage,
		AboutRulesPage
	]
)
class AboutStartPage {
}
