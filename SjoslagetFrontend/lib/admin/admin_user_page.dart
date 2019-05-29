import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/client_factory.dart';
import '../client/user_repository.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-user-page',
	templateUrl: 'admin_user_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, sjoslagetMaterialDirectives, SpinnerWidget],
	exports: <dynamic>[AdminRoutes]
)
class AdminUserPage {
	final ClientFactory _clientFactory;
	final Router _router;
	final UserRepository _userRepository;

	String currentPassword;
	String error;
	String newPassword;

	AdminUserPage(this._clientFactory, this._router, this._userRepository);

	bool get hasError => isNotEmpty(error);

	String get username => _clientFactory.authenticatedUser;

	Future<Null> changePassword() async {
		error = null;

		try {
			final client = _clientFactory.getClient();
			await _userRepository.changePassword(client, username, currentPassword, newPassword);
		} catch (e) {
			print('Failed to change password: ${e.toString()}');
			error = 'Det gick inte att byta lösenord. Kontrollera att det nuvarande lösenordet är rätt.';
		}

		if (null == error) {
			_clientFactory.clear();
			await _router.navigateByUrl(AdminRoutes.login.toUrl());
		}
	}
}
