import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import 'booking_addon_provider.dart';
import 'booking_validator.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_product.dart';
import '../model/booking_product_view.dart';
import '../util/value_converter.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'products-component',
	templateUrl: 'products_component.html',
	styleUrls: const ['../content/content_styles.css', 'products_component.css'],
	directives: const <dynamic>[materialDirectives, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class ProductsComponent implements BookingAddonProvider, OnInit {
	final BookingValidator _bookingValidator;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	List<BookingProduct> _quantitiesFromBooking;

	List<BookingProductView> bookingProducts;
	bool showProductNote = true;

	set quantitiesFromBooking(List<BookingProduct> value) {
		_quantitiesFromBooking = value;
		_setQuantitiesFromBooking();
	}

	bool get isLoaded => null != bookingProducts;

	bool get isValid => bookingProducts.every((p) => p.isValid);

	int get price => bookingProducts.fold(0, (sum, p) => sum + p.price * ValueConverter.toInt(p.quantity));

	ProductsComponent(this._bookingValidator, this._clientFactory, this._cruiseRepository);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			final cruiseProducts = await _cruiseRepository.getActiveCruiseProducts(client);
			bookingProducts = cruiseProducts.map((c) => new BookingProductView.fromCruiseProduct(c)).toList(growable: false);
			_setQuantitiesFromBooking();
		} catch (e) {
			print('Failed to get products due to an exception: ' + e.toString());
			// Ignore this here - we will be stuck in the loading state until the user refreshes
		}
	}

	void validate() {
		bookingProducts.forEach((p) => _bookingValidator.validateProduct(p));
	}

	void _setQuantitiesFromBooking() {
		if (null == bookingProducts)
			return;

		if (null == _quantitiesFromBooking) {
			bookingProducts.forEach((bookingProductView) => bookingProductView.quantity = '');
		} else {
			bookingProducts.forEach((bookingProductView) {
				final bookingProduct = _quantitiesFromBooking.firstWhere((bp) => bp.productTypeId == bookingProductView.id,
					orElse: () => null);
				bookingProductView.quantity = null != bookingProduct ? bookingProduct.quantity.toString() : '';
			});
		}
	}
}
