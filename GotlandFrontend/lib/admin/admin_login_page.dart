import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/widget/modal_dialog.dart';

import '../client/client_factory.dart';
import '../widgets/components.dart';
import 'admin_routes.dart';

// TODO This is almost identical to the one in Sjöslaget, can we reuse it somehow?

@Component(
	selector: 'admin-login-page',
	styleUrls: ['../content/content_styles.css'],
	templateUrl: 'admin_login_page.html',
	directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, gotlandMaterialDirectives, ModalDialog]
)
class AdminLoginPage {
	final ClientFactory _clientFactory;
	final Router _router;

	@ViewChild('loginFailedDialog')
	ModalDialog loginFailedDialog;

	String username;
	String password;

	AdminLoginPage(this._clientFactory, this._router);

	Future<void> logIn() async {
		try {
			await _clientFactory.authenticate(username, password);
		} catch (e) {
			// Handled below since the action is the same for failure as for non-admin
		}

		if (!_clientFactory.isAdmin) {
			_clientFactory.clear();
			loginFailedDialog.open();
		} else {
			await _router.navigateByUrl(AdminRoutes.dashboard.toUrl());
		}
	}

	void leave() {
		_clientFactory.clear();
		window.location.href = '/';
	}
}
