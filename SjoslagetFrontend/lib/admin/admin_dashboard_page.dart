import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

@Component(
	selector: 'admin-dashboard-page',
	templateUrl: 'admin_dashboard_page.html',
	styleUrls: const ['../content/content_styles.css'],
	directives: const [materialDirectives],
	providers: const [materialProviders]
)
class AdminDashboardPage {
}
