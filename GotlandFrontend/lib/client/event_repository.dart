import 'dart:async';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import 'client_factory.dart' show GOTLAND_API_ROOT;
import '../model/event.dart';

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
}
