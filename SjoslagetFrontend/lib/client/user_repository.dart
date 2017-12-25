import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import 'http_status.dart';
import 'io_exception.dart';
import '../model/json_field.dart';

@Injectable()
class UserRepository {
	final String _apiRoot;

	UserRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<Null> changePassword(Client client, String username, String currentPassword, String newPassword) async {
		final headers = _createJsonHeaders();
		final source = JSON.encode({
			USERNAME: username,
			CURRENT_PASSWORD: currentPassword,
			NEW_PASSWORD: newPassword
		});

		Response response;
		try {
			response = await client.post(_apiRoot + '/users/changePassword', headers: headers, body: source);
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}

	Future<String> resetPinCode(Client client, String reference) async {
		final headers = _createJsonHeaders();
		final source = JSON.encode({REFERENCE: reference});

		Response response;
		try {
			response = await client.post(_apiRoot + '/users/resetPinCode', headers: headers, body: source);
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map<String, String> body = JSON.decode(response.body);
		return body[PASSWORD];
	}

	static Map<String, String> _createJsonHeaders() {
		final headers = new Map<String, String>();
		headers['content-type'] = 'application/json';
		return headers;
	}
}
