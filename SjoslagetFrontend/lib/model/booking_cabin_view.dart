import 'booking_pax_view.dart';
import 'cruise_cabin.dart';

class BookingCabinView {
	String id;
	String name;
	int capacity;
	List<BookingPaxView> pax;

	BookingCabinView(CruiseCabin cruiseCabin)
		: id = cruiseCabin.id,
			name = cruiseCabin.name,
			capacity = cruiseCabin.capacity,
			pax = new List<BookingPaxView>(cruiseCabin.capacity) {
		for (int i = 0; i < capacity; i++)
			pax[i] = new BookingPaxView();
	}
}
