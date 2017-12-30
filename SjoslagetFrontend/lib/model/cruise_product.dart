import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class CruiseProduct {
	final String description;
	final String name;
	final String id;
	final String image;
	final int price;

	CruiseProduct(this.id, this.name, this.description, this.image, this.price);

	factory CruiseProduct.fromMap(Map<String, dynamic> json) =>
		new CruiseProduct(json[ID], json[NAME], json[DESCRIPTION], json[IMAGE], _toInt(json[PRICE]));

	static int _toInt(dynamic id) => ValueConverter.toInt(id);
}
