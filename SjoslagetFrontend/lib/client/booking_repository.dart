import 'dart:async';
import 'dart:convert';

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'availability_exception.dart';
import 'booking_exception.dart';
import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import 'http_status.dart';
import 'io_exception.dart';
import '../model/booking_cabin.dart';
import '../model/booking_dashboard_item.dart';
import '../model/booking_details.dart';
import '../model/booking_result.dart';
import '../model/booking_source.dart';

@Injectable()
class BookingRepository {
	final String _apiRoot;

	BookingRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<BookingSource> findBooking(Client client, String reference) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/bookings/' + reference);
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return new BookingSource.fromJson(response.body);
	}

	Future<List<BookingDashboardItem>> getRecentlyUpdated(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/bookings/recentlyUpdated');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body)
			.map((value) => new BookingDashboardItem.fromMap(value))
			.toList();
	}

	Future<BookingResult> saveOrUpdateBooking(Client client, BookingDetails details, List<BookingCabin> cabins) async {
		final headers = new Map<String, String>();
		headers['content-type'] = 'application/json';
		final source = new BookingSource.fromDetails(details, cabins);

		Response response;
		try {
			response = await client.post(_apiRoot + '/bookings', headers: headers, body: source.toJson());
		} catch (e) {
			throw new IOException.fromException(e);
		}

		if (HttpStatus.OK == response.statusCode)
			return new BookingResult.fromJson(response.body);
		else if (HttpStatus.CONFLICT == response.statusCode)
			throw new AvailabilityException();
		else if (HttpStatus.BAD_REQUEST == response.statusCode)
			throw new BookingException();
		else
			throw new IOException.fromResponse(response);
	}
}
