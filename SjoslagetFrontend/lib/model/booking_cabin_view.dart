import 'booking_cabin.dart';
import 'booking_pax_view.dart';
import 'cruise_cabin.dart';

class BookingCabinView {
	String id;
	bool isSaved = false;
	bool isValid = false;
	String name;
	int capacity;
	List<BookingPaxView> pax;
	int price;

	BookingCabinView.fromCruiseCabin(CruiseCabin cruiseCabin)
		: id = cruiseCabin.id,
			name = cruiseCabin.name,
			capacity = cruiseCabin.capacity,
			pax = List<BookingPaxView>(cruiseCabin.capacity),
			price = cruiseCabin.pricePerCabin {
		for (int i = 0; i < capacity; i++) {
			pax[i] = BookingPaxView();
		}

		// First row of every cabin is always required
		pax[0].requiredRow = true;
	}

	factory BookingCabinView.fromBookingCabin(BookingCabin bookingCabin, CruiseCabin cruiseCabin) {
		final view = BookingCabinView.fromCruiseCabin(cruiseCabin);
		view.isSaved = true;
		for (int i = 0; i < bookingCabin.pax.length && i < view.pax.length; i++) {
			view.pax[i] = BookingPaxView.fromBookingPax(bookingCabin.pax[i]);
		}
		return view;
	}

	int get count => paxNotEmpty.length;

	Iterable<BookingPaxView> get paxNotEmpty => pax.where((p) => !p.isEmpty);

	static List<BookingCabinView> listOfBookingCabinToList(List<BookingCabin> bookingCabins, List<CruiseCabin> cruiseCabins) =>
		bookingCabins.map((b) => BookingCabinView.fromBookingCabin(b, _getCruiseCabin(b.cabinTypeId, cruiseCabins))).toList();

	static List<BookingCabin> listToListOfBookingCabin(List<BookingCabinView> list) =>
		list.map((b) => b._toBookingCabin()).toList(growable: false);

	BookingCabin _toBookingCabin() =>
		BookingCabin(null, id, pax.map((p) => p.toBookingPax()).toList(growable: false));

	static CruiseCabin _getCruiseCabin(String id, List<CruiseCabin> cruiseCabins) =>
		cruiseCabins.firstWhere((c) => c.id == id);
}
