import 'dart:convert';

import 'booking_cabin.dart';
import 'booking_details.dart';
import 'booking_product.dart';
import 'json_field.dart';
import 'payment_summary.dart';

class BookingSource extends BookingDetails {
	List<BookingCabin> cabins;
	int discount;
	bool isLocked;
	PaymentSummary payment;
	List<BookingProduct> products;

	BookingSource(String firstName, String lastName, String phoneNo, String email, String lunch, String reference, this.discount, this.isLocked, this.cabins, this.products, this.payment)
		: super(firstName, lastName, phoneNo, email, lunch, reference) {
	}

	BookingSource.fromDetails(BookingDetails details, this.cabins, this.products)
		: super(details.firstName, details.lastName, details.phoneNo, details.email, details.lunch, details.reference) {
	}

	factory BookingSource.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		final List<BookingCabin> cabins = map[CABINS].map((Map<String, dynamic> value) => new BookingCabin.fromMap(value)).toList(growable: false);
		final List<BookingProduct> products = map[PRODUCTS].map((Map<String, dynamic> value) => new BookingProduct.fromMap(value)).toList(growable: false);

		return new BookingSource(
			map[FIRSTNAME],
			map[LASTNAME],
			map[PHONE_NO],
			map[EMAIL],
			map[LUNCH],
			map[REFERENCE],
			map[DISCOUNT],
			map[IS_LOCKED],
			cabins,
			products,
			new PaymentSummary.fromMap(map[PAYMENT])
		);
	}

	String toJson() {
		final cabinsMap = null == cabins ? null : cabins.map((c) => c.toMap()).toList(growable: false);
		final productsMap = null == products ? null : products.where((p) => p.quantity > 0).map((p) => p.toMap()).toList(growable: false);

		return JSON.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			EMAIL: email,
			LUNCH: lunch,
			REFERENCE: reference,
			CABINS: cabinsMap,
			PRODUCTS: productsMap
		});
	}
}
