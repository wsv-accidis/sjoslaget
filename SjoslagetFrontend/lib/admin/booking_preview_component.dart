import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_overview_item.dart';
import '../model/booking_source.dart';
import '../model/cruise_cabin.dart';
import '../model/cruise_product.dart';
import '../model/summary_view.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'booking-preview-component-popup',
	templateUrl: 'booking_preview_component_popup.html',
	styleUrls: const ['../content/content_styles.css', 'booking_preview_component.css'],
	directives: const <dynamic>[ROUTER_DIRECTIVES, materialDirectives, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class BookingPreviewComponentPopup implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	List<CruiseCabin> _cabins;
	List<CruiseProduct> _products;

	BookingSource booking;

	@Input()
	BookingOverviewItem bookingItem;

	List<SummaryView> get cabinSummary {
		final result = new List<SummaryView>();
		if (null == booking || null == _cabins)
			return result;

		for (CruiseCabin cabinType in _cabins) {
			final count = booking.cabins
				.where((bc) => bc.cabinTypeId == cabinType.id)
				.length;
			if (count > 0)
				result.add(new SummaryView(cabinType.id, cabinType.name, count));
		}

		return result;
	}

	bool get isLoaded => null != booking;

	List<SummaryView> get productSummary {
		final result = new List<SummaryView>();
		if (null == booking || null == _products)
			return result;

		for (CruiseProduct productType in _products) {
			final bookingProduct = booking.products.firstWhere(
					(bp) => bp.productTypeId == productType.id, orElse: () => null);
			if (null != bookingProduct && bookingProduct.quantity > 0)
				result.add(new SummaryView(productType.id, productType.name, bookingProduct.quantity));
		}

		return result;
	}

	bool get hasProducts => null != booking && booking.products.isNotEmpty;

	BookingPreviewComponentPopup(this._bookingRepository, this._clientFactory, this._cruiseRepository);

	Future<Null> ngOnInit() async {
		if (null == bookingItem) {
			print('Failed to initialize popup - no item!');
			return;
		}

		try {
			final client = _clientFactory.getClient();
			_cabins = await _cruiseRepository.getActiveCruiseCabins(client);
			_products = await _cruiseRepository.getActiveCruiseProducts(client);
			booking = await _bookingRepository.findBooking(client, bookingItem.reference);
		} catch (e) {
			print('Failed to load booking: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state
		}
	}
}

@Component(
	selector: 'booking-preview-component',
	templateUrl: 'booking_preview_component.html',
	styleUrls: const ['../content/content_styles.css', 'booking_preview_component.css'],
	directives: const <dynamic>[materialDirectives, BookingPreviewComponentPopup],
	providers: const <dynamic>[materialProviders]
)
class BookingPreviewComponent {
	@Input()
	BookingOverviewItem booking;

	bool popupVisible;
}
