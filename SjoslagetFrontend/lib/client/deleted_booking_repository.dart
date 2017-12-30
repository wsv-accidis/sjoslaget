import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import '../model/deleted_booking.dart';

@Injectable()
class DeletedBookingRepository {
	final String _apiRoot;

	DeletedBookingRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<List<DeletedBooking>> getAll(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/bookings/deleted');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return JSON.decode(response.body)
			.map((Map<String, dynamic> value) => new DeletedBooking.fromMap(value))
			.toList();
	}
}
