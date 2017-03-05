import 'dart:async';
import 'dart:html';

import 'package:oauth2/oauth2.dart' as oauth2;

import 'package:angular2/core.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

@Injectable()
class ClientFactory {
	static const TOKEN_KEY = "SjoslagetJwt";
	final String _apiRoot;

	ClientFactory(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<http.Client> authenticate(String username, String password) async {
		final authEndpoint = Uri.parse(_apiRoot + '/token');
		final client = await oauth2.resourceOwnerPasswordGrant(authEndpoint, username, password);
		final credsJson = client.credentials.toJson();
		print('Authenticated successfully with credentials: ' + credsJson);
		window.sessionStorage[TOKEN_KEY] = credsJson;

		return client;
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
			window.sessionStorage.remove(TOKEN_KEY);
			print('Failed to load stored credentials due to an exception: ' + ex);
		}

		return new BrowserClient();
	}

	bool get hasCredentials => window.sessionStorage.containsKey(TOKEN_KEY);
}

const OpaqueToken SJOSLAGET_API_ROOT = const OpaqueToken("sjoslagetApiRoot");
