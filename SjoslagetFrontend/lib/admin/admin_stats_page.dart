import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

import 'admin_routes.dart';

@Component(
	selector: 'admin-stats-page',
	templateUrl: 'admin_stats_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_stats_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, GlyphComponent],
	exports: <dynamic>[AdminRoutes]
)
class AdminStatsPage {
}
