import 'dart:async';

import 'package:angular/angular.dart';
import 'package:frontend_shared/util.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/cruise_cabin.dart';
import '../widgets/spinner_widget.dart';

@Component(
    selector: 'pricing-page',
    styleUrls: ['content_styles.css', 'pricing_page.css'],
    templateUrl: 'pricing_page.html',
    directives: <dynamic>[coreDirectives, SpinnerWidget])
class PricingPage implements OnInit {
  final ClientFactory _clientFactory;
  final CruiseRepository _cruiseRepository;

  List<CruiseCabin> cabins;

  bool get isLoading => null == cabins;

  PricingPage(this._clientFactory, this._cruiseRepository);

  Future<void> doInit() async {
    try {
      final client = _clientFactory.getClient();
      cabins = await _cruiseRepository.getActiveCruiseCabins(client);
    } on ExpirationException {
      rethrow;
    } catch (e) {
      print('Failed to load active cruise cabins: ${e.toString()}');
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

  String priceByName(String subCruise, String name) {
    if (isLoading) {
      return '';
    }

    final CruiseCabin cabin = cabins.firstWhere((c) => c.subCruise == subCruise && c.name == name, orElse: () => null);
    return null != cabin ? CurrencyFormatter.formatIntAsSEK(cabin.pricePerPax) : '-';
  }
}
