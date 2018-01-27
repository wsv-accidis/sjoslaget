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

	factory ReportSummary.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new ReportSummary(
			map[LABELS],
			map[BOOKINGS_CREATED],
			map[BOOKINGS_TOTAL],
			map[CABINS_TOTAL],
			map[PAX_TOTAL],
			map[CAPACITY_TOTAL]
		);
	}
}
