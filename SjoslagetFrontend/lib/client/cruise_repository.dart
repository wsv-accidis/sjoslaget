import 'dart:async';
import 'dart:convert';

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'session_storage_cache.dart';
import '../model/cruise_dabin.dart';

@Injectable()
class CruiseRepository {
	final SessionStorageCache _cache;

	CruiseRepository(SessionStorageCache this._cache);

	Future<List<CruiseCabin>> getActiveCruiseCabins(Client client) async {
		final body = await _cache.get(client, '/cabins/active');
		return JSON.decode(body)
			.map((value) => new CruiseCabin.fromJson(value))
			.toList();
	}
}
