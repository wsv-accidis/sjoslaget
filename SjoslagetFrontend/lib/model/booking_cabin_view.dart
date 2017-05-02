import 'booking_cabin.dart';
import 'booking_pax_view.dart';
import 'cruise_cabin.dart';

class BookingCabinView {
	String id;
	bool isSaved;
	bool isValid;
	String name;
	int capacity;
	List<BookingPaxView> pax;
	int price;

	int get count => paxNotEmpty.length;

	Iterable<BookingPaxView> get paxNotEmpty => pax.where((p) => !p.isEmpty);

	BookingCabinView.fromCruiseCabin(CruiseCabin cruiseCabin)
		: id = cruiseCabin.id,
			name = cruiseCabin.name,
			capacity = cruiseCabin.capacity,
			pax = new List<BookingPaxView>(cruiseCabin.capacity),
			price = cruiseCabin.pricePerCabin {
		for (int i = 0; i < capacity; i++) {
			pax[i] = new BookingPaxView();
		}

		// First row of every cabin is always required
		pax[0].requiredRow = true;
	}

	factory BookingCabinView.fromBookingCabin(BookingCabin bookingCabin, CruiseCabin cruiseCabin) {
		final view = new BookingCabinView.fromCruiseCabin(cruiseCabin);
		view.isSaved = true;
		for (int i = 0; i < bookingCabin.pax.length && i < view.pax.length; i++) {
			view.pax[i] = new BookingPaxView.fromBookingPax(bookingCabin.pax[i]);
		}
		return view;
	}

	static List<BookingCabinView> listOfBookingCabinToList(List<BookingCabin> bookingCabins, List<CruiseCabin> cruiseCabins) {
		return bookingCabins.map((b) => new BookingCabinView.fromBookingCabin(b, _getCruiseCabin(b.cabinTypeId, cruiseCabins))).toList();
	}

	static List<BookingCabin> listToListOfBookingCabin(List<BookingCabinView> list) {
		return list.map((b) => b._toBookingCabin()).toList(growable: false);
	}

	BookingCabin _toBookingCabin() {
		return new BookingCabin(null, id, pax.map((p) => p.toBookingPax()).toList(growable: false));
	}

	static CruiseCabin _getCruiseCabin(String id, List<CruiseCabin> cruiseCabins) {
		return cruiseCabins.firstWhere((c) => c.id == id);
	}
}
