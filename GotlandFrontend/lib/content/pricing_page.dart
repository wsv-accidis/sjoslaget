import 'package:angular/angular.dart';
import 'package:frontend_shared/util.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/cabin_class.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'pricing-page',
	styleUrls: ['content_styles.css', 'pricing_page.css'],
	templateUrl: 'pricing_page.html',
	directives: <dynamic>[coreDirectives, SpinnerWidget]
)
class PricingPage implements OnInit {
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;
	Map<int, CabinClass> _cabins;

	bool get isLoaded => null != _cabins;

	String description(int no) => _cabins.containsKey(no) ? _cabins[no].description : '';

	String price(int no) => !_cabins.containsKey(no) || _cabins[no].pricePerPax.toInt() == 0 ? '?' :
		CurrencyFormatter.formatDecimalAsSEK(_cabins[no].pricePerPax);

	PricingPage(this._clientFactory, this._eventRepository);

	Future<void> doInit() async {
		try {
			final client = _clientFactory.getClient();
			final List<CabinClass> cabinsList = await _eventRepository.getActiveCabinClasses(client);
			_cabins = Map.fromIterable(cabinsList, key: (dynamic c) => c.no);
		} on ExpirationException {
			rethrow;
		} catch (e) {
			print('Failed to load active cabin classes: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	@override
	Future<void> ngOnInit() async {
		try {
			await doInit();
		} on ExpirationException catch (e) {
			print(e.toString());
			_clientFactory.clear();
			await doInit();
		}
	}
}
