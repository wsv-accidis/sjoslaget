import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/client_factory.dart';
import '../client/deleted_booking_repository.dart';
import '../model/deleted_booking.dart';
import '../widgets/sortable_columns.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-deleted-list-page',
	templateUrl: 'admin_deleted_list_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_booking_list_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, materialDirectives, SortableColumnHeader, SortableColumns, SpinnerWidget],
	providers: <dynamic>[materialProviders],
	exports: <dynamic>[AdminRoutes]
)
class AdminDeletedListPage implements OnInit {
	final ClientFactory _clientFactory;
	final DeletedBookingRepository _deletedBookingRepository;

	List<DeletedBooking> _bookings;
	String _filterText = '';

	List<DeletedBooking> bookingsView;
	SortableState sort = SortableState('deleted', true);

	AdminDeletedListPage(this._clientFactory, this._deletedBookingRepository);

	String get filterText => _filterText;

	set filterText(String value) {
		_filterText = value;
		_refreshView();
	}

	bool get isLoading => null == bookingsView;

	String formatCurrency(Decimal amount) => CurrencyFormatter.formatDecimalAsSEK(amount);

	String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

	@override
	Future<Null> ngOnInit() async {
		await refresh();
	}

	void onSortChanged(SortableState state) {
		sort = state;
		_refreshView();
	}

	Future<Null> refresh() async {
		try {
			final client = _clientFactory.getClient();
			_bookings = await _deletedBookingRepository.getAll(client);
			_refreshView();
		} catch (e) {
			print('Failed to load list of deleted bookings: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	int _bookingComparator(DeletedBooking one, DeletedBooking two) {
		if (sort.desc) {
			final DeletedBooking temp = two;
			two = one;
			one = temp;
		}

		switch (sort.column) {
			case 'reference':
				return one.reference.compareTo(two.reference);
			case 'contact':
				return ValueComparer.compareStringPair(one.firstName, one.lastName, two.firstName, two.lastName);
			case 'totalPrice':
				return one.totalPrice.compareTo(two.totalPrice);
			case 'amountPaid':
				return one.amountPaid.compareTo(two.amountPaid);
			case 'updated':
				return one.updated.compareTo(two.updated);
			case 'deleted':
				return one.deleted.compareTo(two.deleted);
			default:
				print('Unrecognized column \"${sort.column}\", no sort applied.');
				return 0;
		}
	}

	void _refreshView() {
		Iterable<DeletedBooking> filtered = _bookings;

		if (isNotEmpty(_filterText)) {
			final filterText = _filterText.toLowerCase().trim();
			filtered = filtered.where((b) => '${b.reference} ${b.firstName} ${b.lastName}'.toLowerCase().contains(filterText));
		}

		final List<DeletedBooking> sorted = filtered.toList(growable: false);
		sorted.sort(_bookingComparator);

		bookingsView = sorted.toList(growable: false);
	}
}
