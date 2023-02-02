import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../../client.dart';
import '../../model/json_field.dart';

class UserRepositoryBase {
	final String _apiRoot;

	UserRepositoryBase(this._apiRoot);

	Future<void> changePassword(Client client, String username, String currentPassword, String newPassword) async {
		final headers = ClientUtil.createJsonHeaders();
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
    final headers = ClientUtil.createJsonHeaders();
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
}
