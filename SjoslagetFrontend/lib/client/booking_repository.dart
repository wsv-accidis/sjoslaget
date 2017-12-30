import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import 'availability_exception.dart';
import 'booking_exception.dart';
import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import '../model/booking_cabin.dart';
import '../model/booking_dashboard_item.dart';
import '../model/booking_details.dart';
import '../model/booking_overview_item.dart';
import '../model/booking_pax_item.dart';
import '../model/booking_product.dart';
import '../model/booking_result.dart';
import '../model/booking_source.dart';
import '../model/json_field.dart';
import '../model/payment_summary.dart';

@Injectable()
class BookingRepository {
	final String _apiRoot;

	BookingRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<Null> deleteBooking(Client client, String reference) async {
		Response response;
		try {
			response = await client.delete(_apiRoot + '/bookings/' + reference);
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}

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

	Future<List<BookingOverviewItem>> getOverview(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/bookings/overview');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body)
			.map((Map<String, dynamic> value) => new BookingOverviewItem.fromMap(value))
			.toList();
	}

	Future<List<BookingPaxItem>> getPax(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/bookings/pax');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body)
			.map((Map<String, dynamic> value) => new BookingPaxItem.fromMap(value))
			.toList();
	}

	Future<List<BookingDashboardItem>> getRecentlyUpdated(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/bookings/recentlyUpdated');
		} on ExpirationException catch (e) {
			throw e; // special case for OAuth2 expiration
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
		return body[IS_LOCKED];
	}

	Future<PaymentSummary> registerPayment(Client client, String reference, Decimal amount) async {
		final headers = _createJsonHeaders();
		final source = JSON.encode({AMOUNT: amount.toDouble()});

		Response response;
		try {
			response = await client.post(_apiRoot + '/bookings/pay/' + reference, headers: headers, body: source);
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return new PaymentSummary.fromJson(response.body);
	}

	Future<Null> updateDiscount(Client client, String reference, int amount) async {
		final headers = _createJsonHeaders();
		final source = JSON.encode({AMOUNT: amount});

		Response response;
		try {
			response = await client.post(_apiRoot + '/bookings/discount/' + reference, headers: headers, body: source);
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}

	Future<BookingResult> saveOrUpdateBooking(Client client, BookingDetails details, List<BookingCabin> cabins, List<BookingProduct> products) async {
		final headers = _createJsonHeaders();
		final source = new BookingSource.fromDetails(details, cabins, products);

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
