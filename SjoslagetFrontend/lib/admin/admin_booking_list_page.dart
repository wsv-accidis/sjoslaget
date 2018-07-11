import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import 'booking_preview_component.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/printer_repository.dart';
import '../model/booking_overview_item.dart';
import '../widgets/paging_support.dart';
import '../widgets/sortable_columns.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-booking-list-page',
	templateUrl: 'admin_booking_list_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css', 'admin_booking_list_page.css'],
	directives: const<dynamic>[CORE_DIRECTIVES, ROUTER_DIRECTIVES, materialDirectives, BookingPreviewComponent, SortableColumnHeader, SortableColumns, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class AdminBookingListPage implements OnInit {
	static final NONE = 'none';
	static final LOCKED = 'locked';
	static final FULLY_PAID = 'fully-paid';
	static final PARTIALLY_PAID = 'partially-paid';
	static final OVER_PAID = 'over-paid';
	static final NOT_PAID = 'not-paid';

	static const PageLimit = 20;

	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final PrinterRepository _printerRepository;

	List<BookingOverviewItem> _bookings;
	String _filterLunch = '';
	String _filterStatus = 'none';
	String _filterText = '';
	Timer _timer;

	@ViewChild('bookingPreview')
	BookingPreviewComponent bookingPreview;

	List<BookingOverviewItem> bookingsView;
	final PagingSupport paging = new PagingSupport(PageLimit);
	bool printerIsAvailable = false;
	SortableState sort = new SortableState('reference', false);

	AdminBookingListPage(this._bookingRepository, this._clientFactory, this._printerRepository);

	String get filterLunch => _filterLunch;

	set filterLunch(String value) {
		_filterLunch = value;
		_refreshView();
	}

	String get filterStatus => _filterStatus;

	set filterStatus(String value) {
		_filterStatus = value;
		_refreshView();
	}

	String get filterText => _filterText;

	set filterText(String value) {
		_filterText = value;
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
		if (item.isOverPaid)
			return OVER_PAID;
		if (item.isUnpaid)
			return NOT_PAID;

		return NONE;
	}

	Future<Null> ngOnInit() async {
		paging.refreshCallback = _refreshView;

		await refresh();
		await _refreshPrinterState();

		_timer = new Timer.periodic(new Duration(seconds: 30), _tick);
	}

	void ngOnDestroy() {
		if (null != _timer)
			_timer.cancel();
	}

	void onFilterChanged() {
		_refreshView();
	}

	void onSortChanged(SortableState state) {
		sort = state;
		_refreshView();
	}

	void openPreviewPopup(BookingOverviewItem booking) {
		bookingPreview.open(booking);
	}

	Future<Null> printBooking(BookingOverviewItem booking) async {
		final client = _clientFactory.getClient();
		await _printerRepository.enqueue(client, booking.reference);
	}

	Future<Null> refresh() async {
		try {
			final client = _clientFactory.getClient();
			_bookings = await _bookingRepository.getOverview(client);
			_refreshView();
		} catch (e) {
			print('Failed to load list of bookings: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
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
				return ValueComparer.compareStringPair(one.firstName, one.lastName, two.firstName, two.lastName);
			case 'lunch':
				return one.lunch.compareTo(two.lunch);
			case 'noOfCabins':
				return one.numberOfCabins - two.numberOfCabins;
			case 'amountPaid':
				return one.amountPaid.compareTo(two.amountPaid);
			case 'amountRemaining':
				return one.amountRemaining.compareTo(two.amountRemaining);
			case 'updated':
				return one.updated.compareTo(two.updated);
			default:
				print('Unrecognized column \"${sort.column}\", no sort applied.');
				return 0;
		}
	}

	Future<Null> _refreshPrinterState() async {
		final client = _clientFactory.getClient();
		printerIsAvailable = await _printerRepository.isAvailable(client);
	}

	void _refreshView() {
		Iterable<BookingOverviewItem> filtered = _bookings;

		if (isNotEmpty(_filterText)) {
			final filterText = _filterText.toLowerCase().trim();
			filtered = filtered.where((b) => '${b.reference} ${b.firstName} ${b.lastName}'.toLowerCase().contains(filterText));
		}
		if (NONE != _filterStatus) {
			filtered = filtered.where((b) => getStatus(b) == _filterStatus);
		}
		if (isNotEmpty(_filterLunch)) {
			filtered = filtered.where((b) => b.lunch == _filterLunch);
		}

		// Can't sort an iterable in Dart without turning it to a list first
		List<BookingOverviewItem> sorted = filtered.toList(growable: false);
		sorted.sort(_bookingComparator);

		bookingsView = paging.apply(sorted);
	}

	static int _statusToInt(BookingOverviewItem item) {
		if (item.isLocked)
			return 4;
		if (item.isFullyPaid)
			return 3;
		if (item.isPartiallyPaid)
			return 2;
		if (item.isOverPaid)
			return 1;
		if (item.isUnpaid)
			return 0;

		return 5;
	}

	Future<Null> _tick(Timer ignored) async {
		await _refreshPrinterState();
	}
}
