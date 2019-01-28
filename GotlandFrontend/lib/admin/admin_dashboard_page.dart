import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../client/client_factory.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-dashboard-page',
	templateUrl: 'admin_dashboard_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_dashboard_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, gotlandMaterialDirectives, SpinnerWidget],
	exports: <dynamic>[AdminRoutes]
)
class AdminDashboardPage implements OnInit {
	final ClientFactory _clientFactory;
	final Router _router;

	AdminDashboardPage(this._clientFactory, this._router);

	@override
	Future<void> ngOnInit() async {
		if (!_clientFactory.isAdmin) {
			await _router.navigateByUrl(AdminRoutes.login.toUrl());
			return;
		}
	}
}
