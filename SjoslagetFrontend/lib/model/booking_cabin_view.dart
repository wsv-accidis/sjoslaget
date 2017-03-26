import 'booking_cabin.dart';
import 'booking_pax.dart';
import 'booking_pax_view.dart';
import 'cruise_cabin.dart';

class BookingCabinView {
	String id;
	bool isValid;
	String name;
	int capacity;
	List<BookingPaxView> pax;

	BookingCabinView(CruiseCabin cruiseCabin)
		: id = cruiseCabin.id,
			name = cruiseCabin.name,
			capacity = cruiseCabin.capacity,
			pax = new List<BookingPaxView>(cruiseCabin.capacity) {
		for (int i = 0; i < capacity; i++) {
			pax[i] = new BookingPaxView();
		}

		// First row of every cabin is always required
		pax[0].requiredRow = true;
	}

	static List<BookingCabin> listToListOfBookingCabin(List<BookingCabinView> list) {
		return list.map((b) => b.toBookingCabin()).toList(growable: false);
	}

	BookingCabin toBookingCabin() {
		return new BookingCabin(
			null,
			id,
			pax.map((p) => _toBookingPax(p)).toList(growable: false)
		);
	}

	static BookingPax _toBookingPax(BookingPaxView pax) {
		return new BookingPax(
			pax.group,
			pax.firstName,
			pax.lastName,
			pax.gender,
			pax.dob,
			pax.nationality,
			_toInt(pax.years)
		);
	}

	static int _toInt(id) {
		if (null == id) return 0;
		return int.parse(id.toString());
	}
}
