import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import '../client/client_factory.dart';
import '../widgets/modal_dialog.dart';

@Component(
	selector: 'admin-login-page',
	styleUrls: const ['../content/content_styles.css'],
	templateUrl: 'admin_login_page.html',
	directives: const<dynamic>[CORE_DIRECTIVES, ROUTER_DIRECTIVES, formDirectives, materialDirectives, ModalDialog],
	providers: const<dynamic>[materialProviders]
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
			_router.navigate(<dynamic>['/Dashboard']);
		}
	}

	void leave() {
		_clientFactory.clear();
		window.location.href = '/';
	}
}
