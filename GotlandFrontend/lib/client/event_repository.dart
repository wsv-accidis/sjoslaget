import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import 'client_factory.dart' show GOTLAND_API_ROOT;
import '../model/cabin_class.dart';
import '../model/event.dart';
import '../model/trip.dart';

@Injectable()
class EventRepository {
	final String _apiRoot;

	EventRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

	Future<Event> getActiveEvent(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/event/active');
		} on ExpirationException catch (e) {
			throw e; // special case for OAuth2 expiration
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return new Event.fromJson(response.body);
	}

	Future<List<CabinClass>> getCabinClasses(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/cabins/classes');
		} on ExpirationException catch (e) {
			throw e; // special case for OAuth2 expiration
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body)
			.map((Map<String, dynamic> value) => new CabinClass.fromMap(value))
			.toList();
	}

	Future<List<Trip>> getInboundTrips(Client client) async {
		return await _getTrips(client, '/trips/inbound');
	}

	Future<List<Trip>> getOutboundTrips(Client client) async {
		return await _getTrips(client, '/trips/outbound');
	}

	Future<List<Trip>> _getTrips(Client client, String uri) async {
		Response response;
		try {
			response = await client.get(_apiRoot + uri);
		} on ExpirationException catch (e) {
			throw e; // special case for OAuth2 expiration
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body)
			.map((Map<String, dynamic> value) => new Trip.fromMap(value))
			.toList();
	}
}
