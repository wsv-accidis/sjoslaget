import 'package:angular/angular.dart';

import '../client/client_factory.dart';
import '../client/external_booking_repository.dart';
import '../model/external_booking.dart';
import '../widgets/spinner_widget.dart';
import 'external_booking_component.dart';

@Component(
	selector: 'external-booking-page',
	templateUrl: 'external_booking_page.html',
	styleUrls: ['../content/content_styles.css'],
	directives: <dynamic>[coreDirectives, ExternalBookingComponent, SpinnerWidget]
)
class ExternalBookingPage implements OnInit {
	final ClientFactory _clientFactory;
	final ExternalBookingRepository _externalBookingRepository;

	bool hasError = false;
	bool isSaving = false;

	@ViewChild('externalBooking')
	ExternalBookingComponent externalBooking;

	ExternalBookingPage(this._clientFactory, this._externalBookingRepository);

	@override
	void ngOnInit() {
		_clientFactory.clear();
	}

	Future<void> submit(ExternalBooking booking) async {
		hasError = false;
		isSaving = true;

		try {
			final client = _clientFactory.getClient();
			await _externalBookingRepository.saveBooking(client, booking);
		} catch (e) {
			print('Failed to confirm booking: ${e.toString()}');
			hasError = true;
		} finally {
			isSaving = false;
		}
	}
}
