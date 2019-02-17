import 'dart:convert';

import 'json_field.dart';

class ClaimedCapacity {
	final int no;
	final int capacity;
	final int preferred;
	final int accepted;

	int get acceptedPercent => (accepted * 100 / capacity).round();

	int get preferredPercent => (preferred * 100 / capacity).round();

	ClaimedCapacity(this.no, this.capacity, this.preferred, this.accepted);

	factory ClaimedCapacity.fromMap(Map<String, dynamic> json) =>
		ClaimedCapacity(json[NO], json[CAPACITY], json[PREFERRED], json[ACCEPTED]);
}
