import 'package:http/http.dart' show Response;

import 'io_exception.dart';

// from http.dart - dart:io is not available in Dartium
abstract class HttpStatus {
	static const int OK = 200;
	static const int BAD_REQUEST = 400;
	static const int CONFLICT = 409;

	static bool isSuccess(int statusCode) {
		return OK == statusCode;
	}

	static void throwIfNotSuccessful(Response response) {
		if (!isSuccess(response.statusCode))
			throw new IOException.fromResponse(response);
	}
}
