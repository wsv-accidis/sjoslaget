import 'dart:async';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import 'http_status.dart';
import 'io_exception.dart';

@Injectable()
class SessionStorageCache {
	static const KEY_PREFIX = 'cache';
	static const KEY_TIMEOUT_PREFIX = 'cache_timeout';

	final String _apiRoot;

	SessionStorageCache(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<String> get(Client client, String uri, int cacheTimeout) async {
		final String key = _getKey(uri);
		final String timeoutKey = _getTimeoutKey(uri);

		if (window.sessionStorage.containsKey(key) && _isCacheValid(timeoutKey, cacheTimeout)) {
			return window.sessionStorage[key];
		} else {
			Response response;
			try {
				response = await client.get(_apiRoot + uri);
			} catch (e) {
				throw new IOException.fromException(e);
			}

			HttpStatus.throwIfNotSuccessful(response);
			final body = response.body;

			window.sessionStorage[timeoutKey] = _now().toString();
			window.sessionStorage[key] = body;

			return body;
		}
	}

	void remove(String uri) {
		window.sessionStorage.remove(_getKey(uri));
		window.sessionStorage.remove(_getTimeoutKey(uri));
	}

	static String _getKey(String uri) => KEY_PREFIX + uri.replaceAll('/', '_');

	static String _getTimeoutKey(String uri) => KEY_TIMEOUT_PREFIX + uri.replaceAll('/', '_');

	bool _isCacheValid(String timeoutKey, int cacheTimeout) {
		if (!window.sessionStorage.containsKey(timeoutKey))
			return false;

		final int cacheTime = int.parse(window.sessionStorage[timeoutKey], onError: (ignored) => 0);
		if (0 == cacheTime)
			return false;

		return cacheTime + cacheTimeout > _now();
	}

	static int _now() => new DateTime.now().millisecondsSinceEpoch;
}
