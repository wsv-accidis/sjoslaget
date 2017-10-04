import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_pax_item.dart';
import '../model/cruise_cabin.dart';
import '../widgets/sortable_columns.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-pax-list-page',
	templateUrl: 'admin_pax_list_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css', 'admin_pax_list_page.css', '../booking/cabins_gender_field.css'],
	directives: const<dynamic>[ROUTER_DIRECTIVES, materialDirectives, SortableColumnHeader, SortableColumns, SpinnerWidget],
	providers: const<dynamic>[materialProviders]
)
class AdminPaxListPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	static const GroupMaxLength = 30;

	String _filterText = '';
	bool _filterYear5;
	List<BookingPaxItem> _pax;

	List<BookingPaxItem> paxView;
	SortableState sort = new SortableState('reference', false);

	int get filteredCount => paxView.length;

	String get filterText => _filterText;

	set filterText(String value) {
		_filterText = value;
		_refreshView();
	}

	bool get filterYear5 => _filterYear5;

	set filterYear5(bool value) {
		_filterYear5 = value;
		_refreshView();
	}

	bool get isLoading => null == paxView;

	int get totalCount => _pax.length;

	AdminPaxListPage(this._bookingRepository, this._clientFactory, this._cruiseRepository);

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
			final cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
			_pax = await _bookingRepository.getPax(client);
			_pax.forEach((p) {
				_limitTextLengths(p);
				_populateCabinType(p, cruiseCabins);
			});

			_refreshView();
		} catch (e) {
			print('Failed to load list of bookings: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	int _bookingComparator(BookingPaxItem one, BookingPaxItem two) {
		if (sort.desc) {
			// Swap the items when using descending sort, so we can keep the rest identical
			BookingPaxItem temp = two;
			two = one;
			one = temp;
		}

		switch (sort.column) {
			case 'reference':
				return one.reference.compareTo(two.reference);
			case 'cabinType':
				return one.cabinType.compareTo(two.cabinType);
			case 'group':
				return one.group.compareTo(two.group);
			case 'name':
				return one.name.compareTo(two.name);
			case 'gender':
				return one.gender.compareTo(two.gender);
			case 'dob':
				return one.dob.compareTo(two.dob);
			case 'nationality':
				return one.nationality.compareTo(two.nationality);
			case 'years':
				return one.years - two.years;
			default:
				print('Unrecognized column \"${sort.column}\", no sort applied.');
				return 0;
		}
	}

	static String _ellipsify(String str, int length) {
		if (isNotEmpty(str) && str.length > length - 3) {
			return str.substring(0, length - 3).trimRight() + '...';
		} else {
			return str;
		}
	}

	static void _limitTextLengths(BookingPaxItem pax) {
		pax.group = _ellipsify(pax.group, GroupMaxLength);
	}

	static void _populateCabinType(BookingPaxItem pax, List<CruiseCabin> cruiseCabins) {
		pax.cabinType = cruiseCabins
			.firstWhere((c) => c.id == pax.cabinTypeId)
			.name;
	}

	void _refreshView() {
		Iterable<BookingPaxItem> filteredList = _pax;

		if (_filterYear5) {
			filteredList = filteredList.where((b) => b.years == 4);
		}
		if (isNotEmpty(_filterText)) {
			final filterText = _filterText.toLowerCase().trim();
			filteredList = filteredList.where((b) => '${b.reference} ${b.group} ${b.name}'.toLowerCase().contains(filterText));
		}

		paxView = filteredList.toList(growable: false);
		paxView.sort(_bookingComparator);
	}
}
