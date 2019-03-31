import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import '../model/external_booking.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class ExternalBookingRepository {
	final String _apiRoot;

	ExternalBookingRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

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
