import 'dart:convert';
import 'json_field.dart';

class ReportSummary {
	final List<String> labels;
	final List<int> bookingsCreated;
	final List<int> bookingsTotal;
	final List<int> cabinsTotal;
	final List<int> paxTotal;
	final List<int> capacityTotal;

	ReportSummary(this.labels, this.bookingsCreated, this.bookingsTotal, this.cabinsTotal, this.paxTotal, this.capacityTotal);

	factory ReportSummary.fromJson(String jsonStr) {
		final Map map = json.decode(jsonStr);
		return ReportSummary(
			_getStrings(map[LABELS]),
			_getInts(map[BOOKINGS_CREATED]),
			_getInts(map[BOOKINGS_TOTAL]),
			_getInts(map[CABINS_TOTAL]),
			_getInts(map[PAX_TOTAL]),
			_getInts(map[CAPACITY_TOTAL])
		);
	}

	static List<int> _getInts(List list) => list.cast<int>().toList();

	static List<String> _getStrings(List list) => list.cast<String>().toList();
}
