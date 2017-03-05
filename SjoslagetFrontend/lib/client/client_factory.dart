import 'dart:async';
import 'dart:html';

import 'package:angular2/core.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:corsac_jwt/corsac_jwt.dart';

@Injectable()
class ClientFactory {
	static const ROLE_KEY = 'role';
	static const TOKEN_KEY = 'jwt';
	static const UNIQUE_NAME_KEY = 'unique_name';

	final String _apiRoot;

	ClientFactory(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<http.Client> authenticate(String username, String password) async {
		try {
			final authEndpoint = Uri.parse(_apiRoot + '/token');
			final client = await oauth2.resourceOwnerPasswordGrant(authEndpoint, username, password);

			final jwt = new JWT.parse(client.credentials.accessToken);
			final credsJson = client.credentials.toJson();

			print('Authentication successful.');
			window.sessionStorage[TOKEN_KEY] = credsJson;
			window.sessionStorage[UNIQUE_NAME_KEY] = jwt.getClaim('unique_name');
			window.sessionStorage[ROLE_KEY] = jwt.getClaim('role');

			return client;
		} catch (e) {
			print('Failed to authenticate due to an exception: ' + e.toString());
			rethrow;
		}
	}

	void clear() {
		window.sessionStorage.remove(ROLE_KEY);
		window.sessionStorage.remove(TOKEN_KEY);
		window.sessionStorage.remove(UNIQUE_NAME_KEY);
		print('Session state cleared.');
	}

	Future<http.Client> getClient() async {
		try {
			if (window.sessionStorage.containsKey(TOKEN_KEY)) {
				final credentials = new oauth2.Credentials.fromJson(window.sessionStorage[TOKEN_KEY]);
				final client = new oauth2.Client(credentials);
				print('Using authenticated client.');
				return client;
			}
		} catch (ex) {
			clear();
			print('Failed to load stored credentials due to an exception: ' + ex);
		}

		return new BrowserClient();
	}

	bool get hasCredentials => window.sessionStorage.containsKey(TOKEN_KEY);

	String get authenticatedRole => window.sessionStorage.containsKey(ROLE_KEY) ? window.sessionStorage[ROLE_KEY] : '';

	String get authenticatedUser => window.sessionStorage.containsKey(UNIQUE_NAME_KEY) ? window.sessionStorage[UNIQUE_NAME_KEY] : '';
}

const OpaqueToken SJOSLAGET_API_ROOT = const OpaqueToken("sjoslagetApiRoot");
