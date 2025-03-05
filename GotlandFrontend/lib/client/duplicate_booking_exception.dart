class DuplicateBookingException implements Exception {
  DuplicateBookingException() {
    print('The booking is a suspected duplicate.');
  }
}
