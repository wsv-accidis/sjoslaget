import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import '../model/json_field.dart';
import 'client_factory.dart' show SJOSLAGET_API_ROOT;

@Injectable()
class UserRepository {
	final String _apiRoot;

	UserRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<Null> changePassword(Client client, String username, String currentPassword, String newPassword) async {
		final headers = _createJsonHeaders();
		final source = json.encode({
			USERNAME: username,
			CURRENT_PASSWORD: currentPassword,
			NEW_PASSWORD: newPassword
		});

		Response response;
		try {
			response = await client.post('$_apiRoot/users/changePassword', headers: headers, body: source);
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}

	Future<String> resetPinCode(Client client, String reference) async {
		final headers = _createJsonHeaders();
		final source = json.encode({REFERENCE: reference});

		Response response;
		try {
			response = await client.post('$_apiRoot/users/resetPinCode', headers: headers, body: source);
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final Map body = json.decode(response.body);
		return body[PASSWORD];
	}

	static Map<String, String> _createJsonHeaders() {
		final headers = <String, String>{};
		headers['content-type'] = 'application/json';
		return headers;
	}
}
