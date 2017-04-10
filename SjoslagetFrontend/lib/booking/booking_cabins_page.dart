import 'dart:async';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import 'booking_component.dart';
import 'cabins_component.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../model/booking_cabin.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_details.dart';
import '../model/booking_result.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'booking-cabins-page',
	templateUrl: 'booking_cabins_page.html',
	styleUrls: const ['../content/content_styles.css', 'booking_cabins_styles.css'],
	directives: const [materialDirectives, SpinnerWidget, CabinsComponent],
	providers: const [materialProviders]
)
class BookingCabinsPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final Router _router;

	@ViewChild('cabins')
	CabinsComponent cabins;

	BookingDetails bookingDetails;
	BookingResult bookingResult;

	bool isSaving = false;

	bool get canFinish => !cabins.isEmpty && isSaved && cabins.isValid && !isSaving;

	bool get canSave => !cabins.isEmpty && cabins.isValid && !isSaving;

	bool get isSaved => null != bookingResult;

	BookingCabinsPage(this._bookingRepository, this._clientFactory, this._router);

	Future<Null> ngOnInit() async {
		if (!window.sessionStorage.containsKey(BookingComponent.BOOKING)) {
			_router.navigate(['/Content/Booking']);
			return;
		}

		bookingDetails = new BookingDetails.fromJson(window.sessionStorage[BookingComponent.BOOKING]);
	}

	void finishBooking() {
		_clientFactory.clear();
		window.sessionStorage.remove(BookingComponent.BOOKING);
		_router.navigate(['/Content/Booking']);
	}

	Future<Null> saveBooking() async {
		isSaving = true;

		List<BookingCabin> cabinsToSave = BookingCabinView.listToListOfBookingCabin(cabins.bookingCabins);

		final client = await _clientFactory.getClient();
		bookingResult = await _bookingRepository.saveOrUpdateBooking(client, bookingDetails, cabinsToSave);

		isSaving = false;
	}
}
