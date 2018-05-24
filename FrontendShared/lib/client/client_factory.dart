import 'dart:async';
import 'dart:html' show Storage, window;

import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:quiver/strings.dart' as str show equalsIgnoreCase;

import 'io_exception.dart';

class ClientFactoryBase {
	static const NAME_KEY = 'client_name';
	static const ROLE_KEY = 'client_role';
	static const TOKEN_KEY = 'client_jwt';

	static const NAME_CLAIM = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
	static const ROLE_CLAIM = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

	final String _apiRoot;
	oauth2.Client _clientInstance;

	ClientFactoryBase(this._apiRoot);

	Future<http.Client> authenticate(String username, String password) async {
		_clear();
		try {
			final authEndpoint = Uri.parse(_apiRoot + '/token');
			final client = await oauth2.resourceOwnerPasswordGrant(authEndpoint, username, password);

			final jwt = new JWT.parse(client.credentials.accessToken);
			final credsJson = client.credentials.toJson();
			final String role = jwt.getClaim(ROLE_CLAIM);
			final String name = jwt.getClaim(NAME_CLAIM);

			print('Authentication successful.');

			final Storage storage = _isAdmin(role)
				? window.localStorage // store admin sessions in localStorage so they persist
				: window.sessionStorage;

			storage[TOKEN_KEY] = credsJson;
			storage[NAME_KEY] = name;
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

		// TODO Cache this instance too
		return new BrowserClient();
	}

	String get authenticatedRole => _getValue(ROLE_KEY);

	String get authenticatedUser => _getValue(NAME_KEY);

	bool get hasCredentials => _hasValue(TOKEN_KEY);

	bool get isAdmin => _isAdmin(authenticatedRole);

	void _clear() {
		_clientInstance = null;

		window.localStorage.remove(ROLE_KEY);
		window.localStorage.remove(TOKEN_KEY);
		window.localStorage.remove(NAME_KEY);

		window.sessionStorage.remove(ROLE_KEY);
		window.sessionStorage.remove(TOKEN_KEY);
		window.sessionStorage.remove(NAME_KEY);
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
