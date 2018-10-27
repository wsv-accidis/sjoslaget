import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../model/cruise.dart';
import '../model/cruise_cabin.dart';
import '../model/cruise_product.dart';
import '../model/json_field.dart';
import 'client_factory.dart' show SJOSLAGET_API_ROOT;

@Injectable()
class CruiseRepository {
	final String _apiRoot;

	CruiseRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<Cruise> getActiveCruise(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/cruise/active');
		} on ExpirationException {
			rethrow; // special case for OAuth2 expiration
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return Cruise.fromJson(response.body);
	}

	Future<List<CruiseCabin>> getActiveCruiseCabins(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/cabins/active');
		} on ExpirationException {
			rethrow; // special case for OAuth2 expiration
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonBody = json.decode(response.body);
		return jsonBody
			.map((dynamic value) => CruiseCabin.fromMap(value))
			.toList();
	}

	Future<List<CruiseProduct>> getActiveCruiseProducts(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/products/active');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonBody = json.decode(response.body);
		return jsonBody
			.map((dynamic value) => CruiseProduct.fromMap(value))
			.toList();
	}

	Future<Map<String, int>> getCabinsAvailability(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/cabins/availability');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map jsonBody = json.decode(response.body);
		return jsonBody.map((dynamic key, dynamic value) => MapEntry<String, int>(key, value));
	}

	Future<Map<String, int>> getProductsAvailability(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/products/availability');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map jsonBody = json.decode(response.body);
		return jsonBody.map((dynamic key, dynamic value) => MapEntry<String, int>(key, value));
	}

	Future<Map<String, int>> getProductsQuantity(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/products/quantity');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map jsonBody = json.decode(response.body);
		return jsonBody.map((dynamic key, dynamic value) => MapEntry<String, int>(key, value));
	}

	Future<bool> lockUnlockCruise(Client client) async {
		Response response;
		try {
			response = await client.put('$_apiRoot/cruise/lock');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map<String, dynamic> jsonBody = json.decode(response.body);
		return jsonBody[IS_LOCKED];
	}
}
