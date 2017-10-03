import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:decimal/decimal.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import 'booking_preview_component.dart';
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
	directives: const<dynamic>[ROUTER_DIRECTIVES, materialDirectives, BookingPreviewComponent, SortableColumnHeader, SortableColumns, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class AdminBookingListPage implements OnInit {
	static final NONE = 'none';
	static final LOCKED = 'locked';
	static final FULLY_PAID = 'fully-paid';
	static final PARTIALLY_PAID = 'partially-paid';
	static final NOT_PAID = 'not-paid';

	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	List<BookingOverviewItem> _bookings;
	String _filterText = '';
	String _filterStatus = 'none';

	SortableState sort = new SortableState('reference', false);
	List<BookingOverviewItem> bookingsView;

	AdminBookingListPage(this._bookingRepository, this._clientFactory);

	String get filterText => _filterText;

	set filterText(String value) {
		_filterText = value;
		_refreshView();
	}

	String get filterStatus => _filterStatus;

	set filterStatus(String value) {
		_filterStatus = value;
		_refreshView();
	}

	bool get isLoading => null == bookingsView;

	String formatCurrency(Decimal amount) => CurrencyFormatter.formatDecimalAsSEK(amount);

	String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

	String getStatus(BookingOverviewItem item) {
		if (item.isLocked)
			return LOCKED;
		if (item.isFullyPaid)
			return FULLY_PAID;
		if (item.isPartiallyPaid)
			return PARTIALLY_PAID;
		if (item.isUnpaid)
			return NOT_PAID;

		return NONE;
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

	void onFilterChanged() {
		_refreshView();
	}

	void onSortChanged(SortableState state) {
		sort = state;
		_refreshView();
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

	void _refreshView() {
		Iterable<BookingOverviewItem> filteredList = _bookings;

		if (isNotEmpty(_filterText)) {
			final filterText = _filterText.toLowerCase().trim();
			filteredList = filteredList.where((b) => '${b.reference} ${b.firstName} ${b.lastName}'.toLowerCase().contains(filterText));
		}
		if (NONE != _filterStatus) {
			filteredList = filteredList.where((b) => getStatus(b) == _filterStatus);
		}

		bookingsView = filteredList.toList(growable: false);
		bookingsView.sort(_bookingComparator);
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
