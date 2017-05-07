import 'dart:async';
import 'dart:convert';

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import 'http_status.dart';
import 'io_exception.dart';
import 'session_storage_cache.dart';
import '../model/cruise.dart';
import '../model/cruise_cabin.dart';

@Injectable()
class CruiseRepository {
	static const ACTIVE_CRUISE_TIMEOUT = 60 * 1000;
	static const ACTIVE_CRUISE_CABINS_TIMEOUT = 30 * 60 * 1000;

	final String _apiRoot;
	final SessionStorageCache _cache;

	CruiseRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot, SessionStorageCache this._cache);

	Future<Cruise> getActiveCruise(Client client) async {
		final body = await _cache.get(client, '/cruise/active', ACTIVE_CRUISE_TIMEOUT);
		return new Cruise.fromJson(body);
	}

	Future<List<CruiseCabin>> getActiveCruiseCabins(Client client) async {
		final body = await _cache.get(client, '/cabins/active', ACTIVE_CRUISE_CABINS_TIMEOUT);
		return JSON.decode(body)
			.map((Map<String, dynamic> value) => new CruiseCabin.fromMap(value))
			.toList();
	}

	Future<Map<String, int>> getAvailability(Client client) async {
		Response response;

		try {
			response = await client.get(_apiRoot + '/cabins/availability');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body);
	}
}
