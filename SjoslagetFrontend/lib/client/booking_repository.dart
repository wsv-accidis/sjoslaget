import 'dart:async';
import 'dart:convert';

import 'package:angular2/core.dart';
import 'package:decimal/decimal.dart';
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
import '../model/payment_summary.dart';

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
			.map((Map<String, dynamic> value) => new BookingDashboardItem.fromMap(value))
			.toList();
	}

	Future<bool> lockUnlockBooking(Client client, String reference) async {
		Response response;

		try {
			response = await client.put(_apiRoot + '/bookings/lock/' + reference);
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map<String, dynamic> body = JSON.decode(response.body);
		return body[BookingSource.IS_LOCKED];
	}

	Future<PaymentSummary> registerPayment(Client client, String reference, Decimal amount) async {
		final headers = _createJsonHeaders();
		final source = JSON.encode({PaymentSummary.AMOUNT: amount.toDouble()});

		Response response;
		try {
			response = await client.post(_apiRoot + '/bookings/pay/' + reference, headers: headers, body: source);
		} catch (e) {
			throw new IOException.fromException(e);
		}

		if (HttpStatus.OK == response.statusCode)
			return new PaymentSummary.fromJson(response.body);
		else
			throw new IOException.fromResponse(response);
	}

	Future<BookingResult> saveOrUpdateBooking(Client client, BookingDetails details, List<BookingCabin> cabins) async {
		final headers = _createJsonHeaders();
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

	static Map<String, String> _createJsonHeaders() {
		final headers = new Map<String, String>();
		headers['content-type'] = 'application/json';
		return headers;
	}
}
