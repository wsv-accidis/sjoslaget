import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import '../model/booking_allocation.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class AllocationRepository {
	final String _apiRoot;

	AllocationRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

	Future<List<BookingAllocation>> getAllocation(Client client, String reference) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/allocation/$reference');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonResult = json.decode(response.body);
		return jsonResult
			.map((dynamic value) => BookingAllocation.fromMap(value))
			.toList();
	}

	Future<void> saveAllocation(Client client, String reference, List<BookingAllocation> allocation) async {
		final headers = ClientUtil.createJsonHeaders();

		Response response;
		try {
			final list = allocation.map((b) => b.toMap()).toList(growable: false);
			response = await client.post('$_apiRoot/allocation/$reference', headers: headers, body: json.encode(list));
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}
}
