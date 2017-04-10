import 'dart:async';

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import '../model/booking_cabin.dart';
import '../model/booking_details.dart';
import '../model/booking_result.dart';
import '../model/booking_source.dart';

@Injectable()
class BookingRepository {
	final String _apiRoot;

	BookingRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<BookingSource> findBooking(Client client, String reference) async {
		final response = await client.get(_apiRoot + '/bookings/' + reference);
		return new BookingSource.fromJson(response.body);
	}

	Future<BookingResult> saveOrUpdateBooking(Client client, BookingDetails details, List<BookingCabin> cabins) async {
		final headers = new Map<String, String>();
		headers['content-type'] = 'application/json';
		final source = new BookingSource.fromDetails(details, cabins);
		final response = await client.post(_apiRoot + '/bookings', headers: headers, body: source.toJson());
		return new BookingResult.fromJson(response.body);
	}
}
