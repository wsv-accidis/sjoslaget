import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/client_factory.dart';
import '../client/user_repository.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-user-page',
	templateUrl: 'admin_user_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_user_page.css'],
	directives: const<dynamic>[ROUTER_DIRECTIVES, materialDirectives, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class AdminUserPage {
	final ClientFactory _clientFactory;
	final Router _router;
	final UserRepository _userRepository;

	String currentPassword;
	String error;
	String newPassword;

	bool get hasError => isNotEmpty(error);

	String get username => _clientFactory.authenticatedUser;

	AdminUserPage(this._clientFactory, this._router, this._userRepository);

	Future<Null> changePassword() async {
		error = null;

		try {
			final client = _clientFactory.getClient();
			await _userRepository.changePassword(client, username, currentPassword, newPassword);
		} catch (e) {
			print('Failed to change password: ' + e.toString());
			error = 'Det gick inte att byta lösenord. Kontrollera att det nuvarande lösenordet är rätt.';
		}

		if (null == error) {
			_clientFactory.clear();
			_router.navigate(<dynamic>['/Admin/Login']);
		}
	}
}
