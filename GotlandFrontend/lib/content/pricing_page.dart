import 'package:angular/angular.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/cabin_class.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'pricing-page',
	styleUrls: ['content_styles.css'],
	templateUrl: 'pricing_page.html',
	directives: <dynamic>[coreDirectives, SpinnerWidget]
)
class PricingPage implements OnInit {
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;

	List<CabinClass> cabins;

	PricingPage(this._clientFactory, this._eventRepository);

	Future<void> doInit() async {
		try {
			final client = _clientFactory.getClient();
			cabins = await _eventRepository.getActiveCabinClasses(client);
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
