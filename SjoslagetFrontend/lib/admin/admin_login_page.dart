import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/client_factory.dart';
import '../widgets/modal_dialog.dart';

@Component(
	selector: 'admin-login-page',
	styleUrls: const ['../content/content_styles.css'],
	templateUrl: 'admin_login_page.html',
	directives: const [ROUTER_DIRECTIVES, materialDirectives, ModalDialog],
	providers: const [materialProviders]
)
class AdminLoginPage {
	final ClientFactory _clientFactory;
	final Router _router;

	@ViewChild('loginFailedDialog')
	ModalDialog loginFailedDialog;

	String username;
	String password;

	AdminLoginPage(this._clientFactory, this._router);

	Future<Null> logIn() async {
		try {
			await _clientFactory.authenticate(username, password);
		} catch (e) {
			// Handled below since the action is the same for failure as for non-admin
		}

		if (!_clientFactory.isAdmin) {
			_clientFactory.clear();
			loginFailedDialog.open();
		} else {
			_router.navigate(['/Admin/Dashboard']);
		}
	}
}
