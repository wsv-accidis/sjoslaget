import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class CruiseProduct {
	final int count;
	final String description;
	final String name;
	final String id;
	final String image;
	final int price;

	CruiseProduct(this.id, this.name, this.description, this.count, this.image, this.price);

	factory CruiseProduct.fromMap(Map<String, dynamic> json) =>
		CruiseProduct(json[ID], json[NAME], json[DESCRIPTION], _toInt(json[COUNT]), json[IMAGE], _toInt(json[PRICE]));

	static int _toInt(dynamic id) => ValueConverter.toInt(id);
}
