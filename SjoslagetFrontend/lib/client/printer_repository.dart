import 'dart:async';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;

@Injectable()
class PrinterRepository {
	static const String TRUE = 'true';

	final String _apiRoot;

	PrinterRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<Null> enqueue(Client client, String reference) async {
		Response response;
		try {
			response = await client.put('$_apiRoot/printer/enqueue/$reference');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}

	Future<bool> isAvailable(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/printer/isavailable');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return TRUE == response.body;
	}
}
