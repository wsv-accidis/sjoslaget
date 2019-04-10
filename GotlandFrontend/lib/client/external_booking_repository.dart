import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import '../model/external_booking.dart';
import '../model/external_booking_type.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class ExternalBookingRepository {
	final String _apiRoot;

	ExternalBookingRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

	Future<List<ExternalBookingType>> getTypes(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/external/types');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonBody = json.decode(response.body);
		return jsonBody
			.map((dynamic value) => ExternalBookingType.fromMap(value))
			.toList();
	}

	Future<void> saveBooking(Client client, ExternalBooking booking) async {
		final headers = ClientUtil.createJsonHeaders();

		Response response;
		try {
			response = await client.post('$_apiRoot/external/create', headers: headers, body: booking.toJson());
		} catch (e) {
			throw IOException.fromException(e);
		}

		if (HttpStatus.OK != response.statusCode)
			throw IOException.fromResponse(response);
	}
}
