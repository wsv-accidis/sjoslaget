import 'dart:async';
import 'dart:convert';

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import 'session_storage_cache.dart';
import '../model/cruise_cabin.dart';

@Injectable()
class CruiseRepository {
	final String _apiRoot;
	final SessionStorageCache _cache;

	CruiseRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot, SessionStorageCache this._cache);

	Future<List<CruiseCabin>> getActiveCruiseCabins(Client client) async {
		final body = await _cache.get(client, '/cabins/active');
		return JSON.decode(body)
			.map((value) => new CruiseCabin.fromJson(value))
			.toList();
	}

	Future<Map<String,int>> getAvailability(Client client) async {
		final response = await client.get(_apiRoot + '/cabins/availability');
		return JSON.decode(response.body);
	}
}
