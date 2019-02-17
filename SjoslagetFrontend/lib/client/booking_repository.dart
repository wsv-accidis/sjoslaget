import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/client.dart';
import 'package:frontend_shared/model.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../model/booking_cabin.dart';
import '../model/booking_dashboard_item.dart';
import '../model/booking_details.dart';
import '../model/booking_overview_item.dart';
import '../model/booking_pax_item.dart';
import '../model/booking_product.dart';
import '../model/booking_source.dart';
import '../model/json_field.dart';
import '../model/payment_summary.dart';
import 'availability_exception.dart';
import 'booking_exception.dart';
import 'client_factory.dart' show SJOSLAGET_API_ROOT;

@Injectable()
class BookingRepository {
	final String _apiRoot;

	BookingRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<Null> deleteBooking(Client client, String reference) async {
		Response response;
		try {
			response = await client.delete('$_apiRoot/bookings/$reference');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}

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

	Future<List<BookingOverviewItem>> getOverview(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/bookings/overview');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonResult = json.decode(response.body);
		return jsonResult
			.map((dynamic value) => BookingOverviewItem.fromMap(value))
			.toList();
	}

	Future<List<BookingPaxItem>> getPax(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/bookings/pax');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonResult = json.decode(response.body);
		return jsonResult
			.map((dynamic value) => BookingPaxItem.fromMap(value))
			.toList();
	}

	Future<List<BookingDashboardItem>> getRecentlyUpdated(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/bookings/recentlyUpdated');
		} on ExpirationException {
			rethrow; // special case for OAuth2 expiration
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonResult = json.decode(response.body);
		return jsonResult
			.map((dynamic value) => BookingDashboardItem.fromMap(value))
			.toList();
	}

	Future<bool> lockUnlockBooking(Client client, String reference) async {
		Response response;
		try {
			response = await client.put('$_apiRoot/bookings/lock/$reference');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map<String, dynamic> body = json.decode(response.body);
		return body[IS_LOCKED];
	}

	Future<PaymentSummary> registerPayment(Client client, String reference, Decimal amount) async {
		final headers = ClientUtil.createJsonHeaders();
		final source = json.encode({AMOUNT: amount.toDouble()});

		Response response;
		try {
			response = await client.post('$_apiRoot/bookings/pay/$reference', headers: headers, body: source);
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return PaymentSummary.fromJson(response.body);
	}

	Future<Null> updateDiscount(Client client, String reference, int amount) async {
		final headers = ClientUtil.createJsonHeaders();
		final source = json.encode({AMOUNT: amount});

		Response response;
		try {
			response = await client.post('$_apiRoot/bookings/discount/$reference', headers: headers, body: source);
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}

	Future<BookingResult> saveOrUpdateBooking(Client client, BookingDetails details, List<BookingCabin> cabins, List<BookingProduct> products) async {
		final headers = ClientUtil.createJsonHeaders();
		final source = BookingSource.fromDetails(details, cabins, products);

		Response response;
		try {
			response = await client.post('$_apiRoot/bookings', headers: headers, body: source.toJson());
		} catch (e) {
			throw IOException.fromException(e);
		}

		if (HttpStatus.OK == response.statusCode)
			return BookingResult.fromJson(response.body);
		else if (HttpStatus.CONFLICT == response.statusCode)
			throw AvailabilityException();
		else if (HttpStatus.BAD_REQUEST == response.statusCode)
			throw BookingException();
		else
			throw IOException.fromResponse(response);
	}
}
