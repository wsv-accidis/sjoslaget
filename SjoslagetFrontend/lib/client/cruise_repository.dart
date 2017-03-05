import 'dart:async';
import 'dart:convert';

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import '../model/cruise_dabin.dart';

@Injectable()
class CruiseRepository {
	final String _apiRoot;

	CruiseRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<List<CruiseCabin>> getActiveCruiseCabins(Client client) async {
		final response = await client.get(_apiRoot + '/cabins/active');
		return JSON.decode(response.body)
			.map((value) => new CruiseCabin.fromJson(value))
			.toList();
	}
}
