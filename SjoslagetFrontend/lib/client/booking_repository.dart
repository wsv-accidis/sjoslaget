import 'dart:async';

import 'package:angular2/core.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import '../model/booking_cabin.dart';
import '../model/booking_details.dart';

@Injectable()
class BookingRepository {
	final String _apiRoot;

	BookingRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<Null> saveOrUpdateBooking(Client client, BookingDetails details, List<BookingCabin> cabins) async {
		final headers = new Map<String, String>();
		headers['content-type'] = 'application/json';
		final body = await client.post(_apiRoot + '/bookings', headers: headers, body: details.toJson(cabins));
	}
}
