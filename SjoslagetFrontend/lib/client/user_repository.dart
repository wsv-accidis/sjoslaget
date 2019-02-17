import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:frontend_shared/client/repository/user_repository_base.dart';
import 'package:http/http.dart';

import '../model/json_field.dart';
import 'client_factory.dart' show SJOSLAGET_API_ROOT;

@Injectable()
class UserRepository extends UserRepositoryBase {
	final String _apiRoot;

	UserRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot) : super(_apiRoot);

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
