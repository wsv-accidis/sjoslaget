import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../model/cabin_class.dart';
import '../model/event.dart';
import '../model/trip.dart';
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

	Future<List<CabinClass>> getCabinClasses(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/cabins/classes');
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

	Future<List<Trip>> getInboundTrips(Client client) async => await _getTrips(client, '/trips/inbound');

	Future<List<Trip>> getOutboundTrips(Client client) async => await _getTrips(client, '/trips/outbound');

	Future<List<Trip>> _getTrips(Client client, String uri) async {
		Response response;
		try {
			response = await client.get('$_apiRoot$uri');
		} on ExpirationException {
			rethrow; // special case for OAuth2 expiration
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonBody = json.decode(response.body);
		return jsonBody
			.map((dynamic value) => Trip.fromMap(value))
			.toList();
	}
}
