import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' as str show isNotEmpty;

import 'booking_product.dart';
import 'cruise_product.dart';

class BookingProductView extends CruiseProduct {
	String quantity;
	String quantityError;

	bool get hasQuantityError => str.isNotEmpty(quantityError);

	bool get isValid => !hasQuantityError;

	String get priceFormatted => CurrencyFormatter.formatIntAsSEK(price);

	BookingProductView(String id, String name, String description, int count, String image, int price)
		: super(id, name, description, count, image, price) {
	}

	BookingProductView.fromCruiseProduct(CruiseProduct product)
		: super(product.id, product.name, product.description, product.count, product.image, product.price) {
	}

	static List<BookingProduct> listToListOfBookingProduct(List<BookingProductView> list) {
		return list.map((b) => b._toBookingProduct()).toList(growable: false);
	}

	void clearErrors() {
		quantityError = null;
	}

	BookingProduct _toBookingProduct() {
		return new BookingProduct(id, ValueConverter.toInt(quantity));
	}
}
