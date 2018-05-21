import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:frontend_shared/util.dart';

import 'booking_addon_provider.dart';
import 'booking_validator.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_product.dart';
import '../model/booking_product_view.dart';
import '../model/cruise_product.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'products-component',
	templateUrl: 'products_component_sj.html',
	styleUrls: const ['../content/content_styles.css', 'products_component.css'],
	directives: const <dynamic>[CORE_DIRECTIVES, formDirectives, materialDirectives, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class ProductsComponent implements BookingAddonProvider, OnInit {
	static const NOT_LIMITED = -1;

	final BookingValidator _bookingValidator;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	Map<String, int> _availability;
	List<BookingProduct> _quantitiesFromBooking;

	List<BookingProductView> bookingProducts;
	List<CruiseProduct> cruiseProducts;
	bool readOnly = false;
	bool showProductNote = true;

	set quantitiesFromBooking(List<BookingProduct> value) {
		_quantitiesFromBooking = value;
		_setQuantitiesFromBooking();
	}

	bool get isLoaded => null != bookingProducts;

	bool get isValid => isLoaded && bookingProducts.every((p) => p.isValid);

	int get price => isLoaded ? bookingProducts.fold(0, (sum, p) => sum + p.price * ValueConverter.toInt(p.quantity)) : 0;

	ProductsComponent(this._bookingValidator, this._clientFactory, this._cruiseRepository);

	bool isLimited(BookingProductView product) => getAvailability(product.id) > NOT_LIMITED;

	int getAvailability(String id) {
		if (null == _availability || !_availability.containsKey(id))
			return NOT_LIMITED;
		return _availability[id];
	}

	int getQuantity(String id) {
		BookingProductView product = bookingProducts.firstWhere((p) => p.id == id, orElse: () => null);
		return product != null ? int.parse(product.quantity) : 0;
	}

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			cruiseProducts = await _cruiseRepository.getActiveCruiseProducts(client);
			bookingProducts = cruiseProducts.map((c) => new BookingProductView.fromCruiseProduct(c)).toList(growable: false);
			_availability = await _cruiseRepository.getProductsAvailability(client);
			_setQuantitiesFromBooking();
		} catch (e) {
			print('Failed to get products due to an exception: ' + e.toString());
			// Ignore this here - we will be stuck in the loading state until the user refreshes
		}
	}

	Future<Null> refreshAvailability() async {
		try {
			final client = _clientFactory.getClient();
			_availability = await _cruiseRepository.getProductsAvailability(client);
		} catch (e) {
			print('Failed to refresh availability due to an exception: ' + e.toString());
			// Ignore this here, keep using old availability
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
