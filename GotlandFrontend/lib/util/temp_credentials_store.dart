import 'dart:html' show Storage, window;

import 'package:angular/angular.dart';
import 'package:frontend_shared/model/booking_result.dart';

@Injectable()
class TempCredentialsStore {
	static const String REFERENCE_KEY = 'temp_reference';
	static const String PIN_KEY = 'temp_pin';

	Storage get _storage => window.sessionStorage;

	void save(BookingResult bookingResult) {
		_storage[REFERENCE_KEY] = bookingResult.reference;
		_storage[PIN_KEY] = bookingResult.password;
	}

	BookingResult load() {
		BookingResult bookingResult;
		if (_storage.containsKey(REFERENCE_KEY) && _storage.containsKey(PIN_KEY)) {
			bookingResult = BookingResult(_storage[REFERENCE_KEY], _storage[PIN_KEY]);
		}

		return bookingResult;
	}

	void clear() {
		_storage.remove(REFERENCE_KEY);
		_storage.remove(PIN_KEY);
	}
}
