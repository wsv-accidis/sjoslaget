import 'package:http/http.dart' show Response;

class IOException implements Exception {
	final String _message;

	IOException(this._message) {
		print(_message);
	}

	factory IOException.fromException(dynamic e) {
		return new IOException('Exception during web request (${e.toString()}).');
	}

	factory IOException.fromResponse(Response response) {
		return new IOException('Server responded with status ${response.statusCode}.');
	}

	String toString() {
		return _message;
	}
}
