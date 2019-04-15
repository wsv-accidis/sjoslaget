import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:frontend_shared/widget/paging_support.dart';
import 'package:frontend_shared/widget/sortable_columns.dart';

import '../client/client_factory.dart';
import '../client/external_booking_repository.dart';
import '../model/external_booking.dart';
import '../model/external_booking_type.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-external-booking-list-page',
	templateUrl: 'admin_external_booking_list_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_external_booking_list_page.css'],
	directives: <dynamic>[coreDirectives, formDirectives, routerDirectives, gotlandMaterialDirectives, SortableColumnHeader, SortableColumns, SpinnerWidget],
	providers: <dynamic>[materialProviders],
	exports: <dynamic>[AdminRoutes]
)
class AdminExternalBookingListPage implements OnInit {
	static const int PAGE_LIMIT = 40;
	static const String STATUS_CONFIRMED = 'confirmed';
	static const String STATUS_EXTERNAL = 'external';
	static const String STATUS_NOT_CONFIRMED = 'not-confirmed';

	final ExternalBookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	List<ExternalBooking> _bookings;
	Map<String, ExternalBookingType> _types;

	List<ExternalBooking> bookingsView;
	final PagingSupport paging = PagingSupport(PAGE_LIMIT);
	SortableState sort = SortableState('name', false);

	AdminExternalBookingListPage(this._bookingRepository, this._clientFactory);

	bool get isLoading => null == bookingsView;

	String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

	String formatType(String typeId) => _types.containsKey(typeId) ? '${_types[typeId].title} (${_types[typeId].price} kr)' : '-';

	String getStatus(ExternalBooking booking) {
		if (booking.paymentReceived) {
			return STATUS_EXTERNAL;
		} else {
			return booking.paymentConfirmed ? STATUS_CONFIRMED : STATUS_NOT_CONFIRMED;
		}
	}

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
			final types = await _bookingRepository.getTypes(client);
			_types = Map.fromIterable(types, key: (dynamic e) => e.id);
			_bookings = await _bookingRepository.getList(client);
			_refreshView();
		} catch (e) {
			print('Failed to load list of external bookings: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	int _comparator(ExternalBooking one, ExternalBooking two) {
		if (sort.desc) {
			final ExternalBooking temp = two;
			two = one;
			one = temp;
		}

		switch (sort.column) {
			case 'paymentStatus':
				return _statusAsInt(getStatus(one)) - _statusAsInt(getStatus(two));
			case 'name':
				return ValueComparer.compareStringPair(one.firstName, one.lastName, two.firstName, two.lastName);
			case 'created':
				return two.created.compareTo(one.created);
			default:
				print('Unrecognized column \"${sort.column}\", no sort applied.');
				return 0;
		}
	}

	void _refreshView() {
		Iterable<ExternalBooking> filtered = _bookings;

		final List<ExternalBooking> sorted = filtered.toList(growable: false);
		sorted.sort(_comparator);

		bookingsView = paging.apply(sorted);
	}

	int _statusAsInt(String status) {
		switch (status) {
			case STATUS_EXTERNAL:
				return 0;
			case STATUS_NOT_CONFIRMED:
				return 1;
			case STATUS_CONFIRMED:
				return 2;
			default:
				return 3;
		}
	}
}
