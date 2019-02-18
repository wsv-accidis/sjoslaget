import 'json_field.dart';

class CabinClassDetail {
	final String id;
	final String title;
	final int no;
	final int capacity;
	final int count;

	CabinClassDetail(this.id, this.title, this.no, this.capacity, this.count);

	factory CabinClassDetail.fromMap(Map<String, dynamic> json) =>
		CabinClassDetail(
			json[ID],
			json[TITLE],
			json[NO],
			json[CAPACITY],
			json[COUNT]
		);
}
