import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:decimal/decimal.dart';

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../model/booking_overview_item.dart';
import '../widgets/spinner_widget.dart';
import '../util/currency_formatter.dart';
import '../util/datetime_formatter.dart';

@Component(
	selector: 'admin-booking-list-page',
	templateUrl: 'admin_booking_list_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css', 'admin_booking_list_page.css'],
	directives: const<dynamic>[ROUTER_DIRECTIVES, materialDirectives, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class AdminBookingListPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	AdminBookingListPage(this._bookingRepository, this._clientFactory);

	List<BookingOverviewItem> bookings;

	bool get isLoading => null == bookings;

	String formatCurrency(Decimal amount) => CurrencyFormatter.formatDecimalAsSEK(amount);

	String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

	String getStatus(BookingOverviewItem item) {
		if(item.isLocked)
			return 'locked';
		if(item.isFullyPaid)
			return 'fully-paid';
		if(item.isPartiallyPaid)
			return 'partially-paid';
		if(item.isUnpaid)
			return 'not-paid';

		return '';
	}

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			bookings = await _bookingRepository.getOverview(client);
		} catch (e) {
			print('Failed to load list of bookings: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}
}
