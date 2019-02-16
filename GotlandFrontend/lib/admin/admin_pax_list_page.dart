import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util/value_comparer.dart';
import 'package:frontend_shared/widget/paging_support.dart';
import 'package:frontend_shared/widget/sortable_columns.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../model/booking_pax_list_item.dart';
import '../util/gender.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-pax-list-page',
	templateUrl: 'admin_pax_list_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_pax_list_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, gotlandMaterialDirectives, SortableColumnHeader, SortableColumns, SpinnerWidget],
	exports: <dynamic>[AdminRoutes]
)
class AdminPaxListPage implements OnInit {
	static const int PAGE_LIMIT = 60;

	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	String _filterText = '';
	List<BookingPaxListItem> _pax;

	final PagingSupport paging = PagingSupport(PAGE_LIMIT);
	List<BookingPaxListItem> paxView;
	SortableState sort = SortableState('name', false);

	AdminPaxListPage(this._bookingRepository, this._clientFactory);

	String get filterText => _filterText;

	set filterText(String value) {
		_filterText = value;
		_refreshView();
	}

	bool get isLoading => null == paxView;

	String genderToString(String g) => Gender.asString(g);

	@override
	Future<void> ngOnInit() async {
		paging.refreshCallback = _refreshView;
		await refresh();
	}

	void onSortChanged(SortableState state) {
		sort = state;
		_refreshView();
	}

	Future<void> refresh() async {
		try {
			final client = _clientFactory.getClient();
			_pax = await _bookingRepository.getListOfPax(client);
			_refreshView();
		} catch (e) {
			print('Failed to load list of pax: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	int _comparator(BookingPaxListItem one, BookingPaxListItem two) {
		if (sort.desc) {
			final BookingPaxListItem temp = two;
			two = one;
			one = temp;
		}

		switch (sort.column) {
			case 'reference':
				return one.reference.compareTo(two.reference);
			case 'teamName':
				return one.teamName.compareTo(two.teamName);
			case 'name':
				return ValueComparer.compareStringPair(one.firstName, one.lastName, two.firstName, two.lastName);
			case 'gender':
				return one.gender.compareTo(two.gender);
			case 'dob':
				return one.dob.compareTo(two.dob);
			case 'cabinClassMin':
				return one.cabinClassMin - two.cabinClassMin;
			case 'cabinClassPreferred':
				return one.cabinClassPreferred - two.cabinClassPreferred;
			case 'cabinClassMax':
				return one.cabinClassMax - two.cabinClassMax;
			default:
				print('Unrecognized column \"${sort.column}\", no sort applied.');
				return 0;
		}
	}

	void _refreshView() {
		Iterable<BookingPaxListItem> filtered = _pax;

		if (isNotEmpty(_filterText)) {
			final filterText = _filterText.toLowerCase().trim();
			filtered = filtered.where((b) => '${b.reference} ${b.teamName} ${b.firstName} ${b.lastName}'.toLowerCase().contains(filterText));
		}

		final List<BookingPaxListItem> sorted = filtered.toList(growable: false);
		sorted.sort(_comparator);

		paxView = paging.apply(sorted);
	}
}
