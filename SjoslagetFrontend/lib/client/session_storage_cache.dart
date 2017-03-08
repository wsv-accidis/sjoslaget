import 'dart:async';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;

@Injectable()
class SessionStorageCache {
	static const KEY_PREFIX = 'cache';

	final String _apiRoot;

	SessionStorageCache(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<String> get(Client client, String uri) async {
		final String key = KEY_PREFIX + uri.replaceAll('/', '_');

		if (window.sessionStorage.containsKey(key)) {
			// TODO: Implement cache timeouts
			return window.sessionStorage[key];
		} else {
			final response = await client.get(_apiRoot + uri);
			final body = response.body;
			window.sessionStorage[key] = body;
			return body;
		}
	}
}
