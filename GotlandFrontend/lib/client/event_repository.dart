import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../model/cabin_class_detail.dart';
import '../model/cabin_class.dart';
import '../model/claimed_capacity.dart';
import '../model/event.dart';
import '../model/json_field.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class EventRepository {
	final String _apiRoot;

	EventRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

	Future<Event> getActiveEvent(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/event/active');
		} on ExpirationException {
			rethrow; // special case for OAuth2 expiration
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return Event.fromJson(response.body);
	}

	Future<List<CabinClass>> getActiveCabinClasses(Client client) async {
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
			.map((dynamic value) => CabinClass.fromMap(value))
			.toList();
	}

	Future<List<CabinClassDetail>> getCabinClassDetails(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/cabins/details');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonBody = json.decode(response.body);
		return jsonBody
			.map((dynamic value) => CabinClassDetail.fromMap(value))
			.toList();
	}

	Future<List<ClaimedCapacity>> getClaimedCapacity(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/cabins/claimedCapacity');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonBody = json.decode(response.body);
		return jsonBody
			.map((dynamic value) => ClaimedCapacity.fromMap(value))
			.toList();
	}

	Future<bool> lockUnlockEvent(Client client) async {
		Response response;
		try {
			response = await client.put('$_apiRoot/event/lock');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map<String, dynamic> jsonBody = json.decode(response.body);
		return jsonBody[IS_LOCKED];
	}
}
