import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import 'http_status.dart';
import 'io_exception.dart';
import '../model/cruise.dart';
import '../model/cruise_cabin.dart';
import '../model/cruise_product.dart';

@Injectable()
class CruiseRepository {
	final String _apiRoot;

	CruiseRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<Cruise> getActiveCruise(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/cruise/active');
		} on ExpirationException catch (e) {
			throw e; // special case for dashboard
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return new Cruise.fromJson(response.body);
	}

	Future<List<CruiseCabin>> getActiveCruiseCabins(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/cabins/active');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body)
			.map((Map<String, dynamic> value) => new CruiseCabin.fromMap(value))
			.toList();
	}

	Future<List<CruiseProduct>> getActiveCruiseProducts(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/products/active');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body)
			.map((Map<String, dynamic> value) => new CruiseProduct.fromMap(value))
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

	Future<bool> lockUnlockCruise(Client client) async {
		Response response;
		try {
			response = await client.put(_apiRoot + '/cruise/lock');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map<String, dynamic> body = JSON.decode(response.body);
		return body[Cruise.IS_LOCKED];
	}
}
