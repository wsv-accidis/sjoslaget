import 'dart:async';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:quiver/strings.dart' show equalsIgnoreCase;

@Injectable()
class ClientFactory {
	static const ROLE_KEY = 'client_role';
	static const TOKEN_KEY = 'client_jwt';
	static const UNIQUE_NAME_KEY = 'client_name';

	final String _apiRoot;
	oauth2.Client _clientInstance;

	ClientFactory(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<http.Client> authenticate(String username, String password) async {
		_clear();
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
		_clear();
		print('Session state cleared.');
	}

	Future<http.Client> getClient() async {
		try {
			if (window.sessionStorage.containsKey(TOKEN_KEY)) {
				if (null != _clientInstance)
					return _clientInstance;

				final credentials = new oauth2.Credentials.fromJson(window.sessionStorage[TOKEN_KEY]);
				_clientInstance = new oauth2.Client(credentials);
				print('Using authenticated client.');
				return _clientInstance;
			}
		} catch (ex) {
			_clear();
			print('Failed to load stored credentials due to an exception: ' + ex);
		}

		return new BrowserClient();
	}

	String get authenticatedRole => window.sessionStorage.containsKey(ROLE_KEY) ? window.sessionStorage[ROLE_KEY] : '';

	String get authenticatedUser => window.sessionStorage.containsKey(UNIQUE_NAME_KEY) ? window.sessionStorage[UNIQUE_NAME_KEY] : '';

	bool get hasCredentials => window.sessionStorage.containsKey(TOKEN_KEY);

	bool get isAdmin => equalsIgnoreCase('admin', authenticatedRole);

	void _clear() {
		_clientInstance = null;
		window.sessionStorage.remove(ROLE_KEY);
		window.sessionStorage.remove(TOKEN_KEY);
		window.sessionStorage.remove(UNIQUE_NAME_KEY);
	}
}

const OpaqueToken SJOSLAGET_API_ROOT = const OpaqueToken('sjoslagetApiRoot');
