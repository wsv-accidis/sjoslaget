import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:frontend_shared/model/booking_result.dart';
import 'package:http/http.dart';

import '../model/booking_list_item.dart';
import '../model/booking_pax_list_item.dart';
import '../model/booking_queue_stats.dart';
import '../model/booking_source.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class BookingRepository {
	final String _apiRoot;

	BookingRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

	Future<BookingSource> getBooking(Client client, String reference) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/bookings/$reference');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return BookingSource.fromJson(response.body);
	}

	Future<List<BookingListItem>> getList(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/bookings/list');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonResult = json.decode(response.body);
		return jsonResult
			.map((dynamic value) => BookingListItem.fromMap(value))
			.toList();
	}

	Future<List<BookingPaxListItem>> getListOfPax(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/bookings/pax');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonResult = json.decode(response.body);
		return jsonResult
			.map((dynamic value) => BookingPaxListItem.fromMap(value))
			.toList();
	}

	Future<BookingQueueStats> getQueueStats(Client client, String reference) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/bookings/$reference/queueStats');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return BookingQueueStats.fromJson(response.body);
	}

	Future<BookingResult> saveBooking(Client client, BookingSource booking) async {
		final headers = _createJsonHeaders();

		Response response;
		try {
			response = await client.post('$_apiRoot/bookings', headers: headers, body: booking.toJson());
		} catch (e) {
			throw IOException.fromException(e);
		}

		if (HttpStatus.OK == response.statusCode)
			return BookingResult.fromJson(response.body);
		//else if (HttpStatus.BAD_REQUEST == response.statusCode) TODO For validation errors
		//throw BookingException();
		else
			throw IOException.fromResponse(response);
	}

	static Map<String, String> _createJsonHeaders() {
		final headers = <String, String>{};
		headers['content-type'] = 'application/json';
		return headers;
	}
}
