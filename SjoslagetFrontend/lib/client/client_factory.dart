import 'dart:async';
import 'dart:html' show Storage, window;

import 'package:angular/angular.dart';
import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:quiver/strings.dart' as str show equalsIgnoreCase;

import 'io_exception.dart';

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
			final String role = jwt.getClaim('role');
			final String uniqueName = jwt.getClaim('unique_name');

			print('Authentication successful.');

			final Storage storage = _isAdmin(role)
				? window.localStorage // store admin sessions in localStorage so they persist
				: window.sessionStorage;

			storage[TOKEN_KEY] = credsJson;
			storage[UNIQUE_NAME_KEY] = uniqueName;
			storage[ROLE_KEY] = role;

			return client;
		} catch (e) {
			throw new IOException.fromException(e);
		}
	}

	void clear() {
		_clear();
		print('Session state cleared.');
	}

	http.Client getClient() {
		try {
			if (hasCredentials) {
				if (null != _clientInstance)
					return _clientInstance;

				final credentials = new oauth2.Credentials.fromJson(_getValue(TOKEN_KEY));
				_clientInstance = new oauth2.Client(credentials);
				print('Using authenticated client.');
				return _clientInstance;
			}
		} catch (e) {
			_clear();
			print('Failed to load stored credentials due to an exception: ' + e.toString());
		}

		return new BrowserClient();
	}

	String get authenticatedRole => _getValue(ROLE_KEY);

	String get authenticatedUser => _getValue(UNIQUE_NAME_KEY);

	bool get hasCredentials => _hasValue(TOKEN_KEY);

	bool get isAdmin => _isAdmin(authenticatedRole);

	void _clear() {
		_clientInstance = null;

		window.localStorage.remove(ROLE_KEY);
		window.localStorage.remove(TOKEN_KEY);
		window.localStorage.remove(UNIQUE_NAME_KEY);

		window.sessionStorage.remove(ROLE_KEY);
		window.sessionStorage.remove(TOKEN_KEY);
		window.sessionStorage.remove(UNIQUE_NAME_KEY);
	}

	String _getValue(String key) {
		if (window.sessionStorage.containsKey(key)) {
			return window.sessionStorage[key];
		} else if (window.localStorage.containsKey(key)) {
			return window.localStorage[key];
		} else {
			return '';
		}
	}

	bool _hasValue(String key) => window.sessionStorage.containsKey(key) || window.localStorage.containsKey(key);

	bool _isAdmin(String role) => str.equalsIgnoreCase('admin', role);
}

const OpaqueToken SJOSLAGET_API_ROOT = const OpaqueToken('sjoslagetApiRoot');
