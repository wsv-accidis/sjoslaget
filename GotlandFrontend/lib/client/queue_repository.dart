import 'dart:async';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import 'booking_exception.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;
import '../model/booking_details.dart';
import '../model/candidate_response.dart';

@Injectable()
class QueueRepository {
	final String _apiRoot;

	QueueRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

	Future<CandidateResponse> createCandidate(Client client, BookingDetails candidate) async {
		final headers = _createJsonHeaders();

		Response response;
		try {
			response = await client.post(_apiRoot + '/queue/create', headers: headers, body: candidate.toJson());
		} catch (e) {
			throw new IOException.fromException(e);
		}

		if (HttpStatus.OK == response.statusCode)
			return new CandidateResponse.fromJson(response.body);
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
