import 'dart:convert';

import 'package:frontend_shared/model.dart' show PaymentSummary;

import 'booking_cabin.dart';
import 'booking_details.dart';
import 'booking_product.dart';
import 'json_field.dart';

class BookingSource extends BookingDetails {
	List<BookingCabin> cabins;
	int discount;
	bool isLocked;
	PaymentSummary payment;
	List<BookingProduct> products;

	BookingSource(String firstName, String lastName, String phoneNo, String email, String lunch, String reference, String internalNotes, this.discount, this.isLocked, this.cabins, this.products, this.payment)
		: super(firstName, lastName, phoneNo, email, lunch, reference, internalNotes);

	BookingSource.fromDetails(BookingDetails details, this.cabins, this.products)
		: super(details.firstName, details.lastName, details.phoneNo, details.email, details.lunch, details.reference, details.internalNotes);

	factory BookingSource.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		final List<BookingCabin> cabins = map[CABINS]
			.map((dynamic value) => BookingCabin.fromMap(value))
			.cast<BookingCabin>()
			.toList(growable: false);

		final List<BookingProduct> products = map[PRODUCTS]
			.map((dynamic value) => BookingProduct.fromMap(value))
			.cast<BookingProduct>()
			.toList(growable: false);

		return BookingSource(
			map[FIRSTNAME],
			map[LASTNAME],
			map[PHONE_NO],
			map[EMAIL],
			map[LUNCH],
			map[REFERENCE],
			map[INTERNAL_NOTES],
			map[DISCOUNT],
			map[IS_LOCKED],
			cabins,
			products,
			PaymentSummary.fromMap(map[PAYMENT])
		);
	}

	@override
	String toJson() {
		final cabinsMap = null == cabins ? null : cabins.map((c) => c.toMap()).toList(growable: false);
		final productsMap = null == products ? null : products.where((p) => p.quantity > 0).map((p) => p.toMap()).toList(growable: false);

		return json.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			EMAIL: email,
			LUNCH: lunch,
			REFERENCE: reference,
			INTERNAL_NOTES: internalNotes,
			CABINS: cabinsMap,
			PRODUCTS: productsMap
		});
	}
}
