import 'package:quiver/strings.dart' as str show isEmpty;

import 'booking_product.dart';
import 'cruise_product.dart';
import '../util/currency_formatter.dart';
import '../util/value_converter.dart';

class BookingProductView extends CruiseProduct {
	String quantity;
	String quantityError;

	bool get hasQuantityError => !str.isEmpty(quantityError);

	bool get isValid => !hasQuantityError;

	String get priceFormatted => CurrencyFormatter.formatIntAsSEK(price);

	BookingProductView(String id, String name, String description, String image, int price)
		: super(id, name, description, image, price) {
	}

	BookingProductView.fromCruiseProduct(CruiseProduct product)
		: super(product.id, product.name, product.description, product.image, product.price) {
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
