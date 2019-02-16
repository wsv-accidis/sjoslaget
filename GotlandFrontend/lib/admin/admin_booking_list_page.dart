import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/model/booking_payment_model.dart';
import 'package:frontend_shared/util.dart';
import 'package:frontend_shared/widget/paging_support.dart';
import 'package:frontend_shared/widget/sortable_columns.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../model/booking_list_item.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-booking-list-page',
	templateUrl: 'admin_booking_list_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_booking_list_page.css'],
	directives: <dynamic>[coreDirectives, formDirectives, routerDirectives, gotlandMaterialDirectives, SortableColumnHeader, SortableColumns, SpinnerWidget],
	providers: <dynamic>[materialProviders],
	exports: <dynamic>[AdminRoutes]
)
class AdminBookingListPage implements OnInit {
	static const int PAGE_LIMIT = 20;

	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	List<BookingListItem> _bookings;
	String _filterStatus = BookingPaymentModel.STATUS_NONE;
	String _filterText = '';

	List<BookingListItem> bookingsView;
	final PagingSupport paging = PagingSupport(PAGE_LIMIT);
	SortableState sort = SortableState('queueNo', false);

	AdminBookingListPage(this._bookingRepository, this._clientFactory);

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

	@override
	Future<void> ngOnInit() async {
		paging.refreshCallback = _refreshView;
		await refresh();
	}

	void onFilterChanged() {
		_refreshView();
	}

	void onSortChanged(SortableState state) {
		sort = state;
		_refreshView();
	}

	Future<void> refresh() async {
		try {
			final client = _clientFactory.getClient();
			_bookings = await _bookingRepository.getList(client);
			_refreshView();
		} catch (e) {
			print('Failed to load list of bookings: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	int _bookingComparator(BookingListItem one, BookingListItem two) {
		if (sort.desc) {
			final BookingListItem temp = two;
			two = one;
			one = temp;
		}

		switch (sort.column) {
			case 'status':
				return one.statusAsInt - two.statusAsInt;
			case 'reference':
				return one.reference.compareTo(two.reference);
			case 'teamName':
				return one.teamName.compareTo(two.teamName);
			case 'contact':
				return ValueComparer.compareStringPair(one.firstName, one.lastName, two.firstName, two.lastName);
			case 'numberOfPax':
				return one.numberOfPax - two.numberOfPax;
			case 'queueNo':
				return one.queueNo - two.queueNo;
			case 'amountPaid':
				return one.amountPaid.compareTo(two.amountPaid);
			case 'amountRemaining':
				return one.amountRemaining.compareTo(two.amountRemaining);
			case 'updated':
				return two.updated.compareTo(one.updated);
			default:
				print('Unrecognized column \"${sort.column}\", no sort applied.');
				return 0;
		}
	}

	void _refreshView() {
		Iterable<BookingListItem> filtered = _bookings;

		if (isNotEmpty(_filterText)) {
			final filterText = _filterText.toLowerCase().trim();
			filtered = filtered.where((b) => '${b.reference} ${b.teamName} ${b.firstName} ${b.lastName}'.toLowerCase().contains(filterText));
		}
		if (BookingPaymentModel.STATUS_NONE != _filterStatus) {
			filtered = filtered.where((b) => b.status == _filterStatus);
		}

		final List<BookingListItem> sorted = filtered.toList(growable: false);
		sorted.sort(_bookingComparator);

		bookingsView = paging.apply(sorted);
	}
}
