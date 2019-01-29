import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../model/event_countdown.dart';
import '../model/queue_dashboard_item.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class QueueAdminRepository {
	final String _apiRoot;

	QueueAdminRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

	Future<EventCountdown> getCountdown(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/queueAdmin/countdown');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return EventCountdown.fromJson(response.body);
	}

	Future<List<QueueDashboardItem>> getQueue(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/queueAdmin/dashboard');
		} on ExpirationException {
			rethrow; // special case for OAuth2 expiration
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonResult = json.decode(response.body);
		return jsonResult
			.map((dynamic value) => QueueDashboardItem.fromMap(value))
			.toList(growable: false);
	}
}
