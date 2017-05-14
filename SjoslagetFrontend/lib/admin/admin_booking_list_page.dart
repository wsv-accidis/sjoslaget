import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:decimal/decimal.dart';

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../model/booking_overview_item.dart';
import '../widgets/sortable_columns.dart';
import '../widgets/spinner_widget.dart';
import '../util/currency_formatter.dart';
import '../util/datetime_formatter.dart';

@Component(
	selector: 'admin-booking-list-page',
	templateUrl: 'admin_booking_list_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css', 'admin_booking_list_page.css'],
	directives: const<dynamic>[ROUTER_DIRECTIVES, materialDirectives, SortableColumnHeader, SortableColumns, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class AdminBookingListPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	List<BookingOverviewItem> _bookings;
	SortableState sort = new SortableState('reference', false);

	AdminBookingListPage(this._bookingRepository, this._clientFactory);

	List<BookingOverviewItem> bookingsView;

	bool get isLoading => null == bookingsView;

	String formatCurrency(Decimal amount) => CurrencyFormatter.formatDecimalAsSEK(amount);

	String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

	String getStatus(BookingOverviewItem item) {
		if (item.isLocked)
			return 'locked';
		if (item.isFullyPaid)
			return 'fully-paid';
		if (item.isPartiallyPaid)
			return 'partially-paid';
		if (item.isUnpaid)
			return 'not-paid';

		return '';
	}

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			_bookings = await _bookingRepository.getOverview(client);
			bookingsView = _bookings;
		} catch (e) {
			print('Failed to load list of bookings: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	void onSortChanged(SortableState state) {
		sort = state;
		_refreshView();
	}

	void _refreshView() {
		bookingsView = new List.from(_bookings);
		bookingsView.sort(_bookingComparator);
	}

	int _bookingComparator(BookingOverviewItem one, BookingOverviewItem two) {
		if (sort.desc) {
			// Swap the items when using descending sort, so we can keep the rest identical
			BookingOverviewItem temp = two;
			two = one;
			one = temp;
		}

		switch (sort.column) {
			case 'status':
				return _statusToInt(one) - _statusToInt(two);
			case 'reference':
				return one.reference.compareTo(two.reference);
			case 'contact':
				int result = one.firstName.compareTo(two.firstName);
				return 0 != result ? result : one.lastName.compareTo(two.lastName);
			case 'noOfCabins':
				return one.numberOfCabins - two.numberOfCabins;
			case 'amountPaid':
				return one.amountPaid > two.amountPaid ? 1 : (one.amountPaid < two.amountPaid ? -1 : 0);
			case 'amountRemaining':
				return one.amountRemaining > two.amountRemaining ? 1 : (one.amountRemaining < two.amountRemaining ? -1 : 0);
			case 'updated':
				return one.updated.isAfter(two.updated) ? 1 : (one.updated.isBefore(two.updated) ? -1 : 0);
			default:
				print('Unrecognized column \"${sort.column}\", no sort applied.');
				return 0;
		}
	}

	static int _statusToInt(BookingOverviewItem item) {
		if (item.isLocked)
			return 3;
		if (item.isFullyPaid)
			return 2;
		if (item.isPartiallyPaid)
			return 1;
		if (item.isUnpaid)
			return 0;

		return 4;
	}
}
