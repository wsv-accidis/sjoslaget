import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../model/booking_pax_item.dart';
import '../widgets/sortable_columns.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-pax-list-page',
	templateUrl: 'admin_pax_list_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css'],
	directives: const<dynamic>[ROUTER_DIRECTIVES, materialDirectives, SortableColumnHeader, SortableColumns, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class AdminPaxListPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	List<BookingPaxItem> _pax;

	List<BookingPaxItem> paxView;
	SortableState sort = new SortableState('reference', false);

	bool get isLoading => null == paxView;

	AdminPaxListPage(this._bookingRepository, this._clientFactory);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			_pax = await _bookingRepository.getPax(client);
			paxView = _pax;
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

	}
}
