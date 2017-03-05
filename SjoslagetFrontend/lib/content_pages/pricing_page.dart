import 'dart:async';

import 'package:angular2/core.dart';

import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/cruise_dabin.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'pricing-page',
	styleUrls: const ['content_styles.css'],
	templateUrl: 'pricing_page.html',
	directives: const [SpinnerWidget]
)
class PricingPage implements OnInit {
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	List<CruiseCabin> cabins;

	PricingPage(this._clientFactory, this._cruiseRepository);

	Future<Null> ngOnInit() async {
		final client = await _clientFactory.createClient();
		cabins = await _cruiseRepository.getActiveCruiseCabins(client);
	}
}
