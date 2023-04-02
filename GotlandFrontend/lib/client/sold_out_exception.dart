class SoldOutException implements Exception {
	SoldOutException() {
		print('Event has sold out, unable to save booking.');
	}
}
