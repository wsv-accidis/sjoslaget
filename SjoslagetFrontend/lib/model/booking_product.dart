import 'json_field.dart';

class BookingProduct {
	final String productTypeId;
	final int quantity;

	BookingProduct(this.productTypeId, this.quantity);

	factory BookingProduct.fromMap(Map<String, dynamic> map) =>
		BookingProduct(map[PRODUCT_TYPE_ID], map[QUANTITY]);

	Map<String, dynamic> toMap() =>
		<String, dynamic>{
			PRODUCT_TYPE_ID: productTypeId,
			QUANTITY: quantity
		};
}
