import 'dart:convert';
import 'json_field.dart';

import 'string_pair.dart';

class ReportData {
	final List<KeyValuePair> ageDistribution;
	final List<KeyValuePair> bookingsByPayment;
	final List<KeyValuePair> genders;
	final List<KeyValuePair> topContacts;
	final List<KeyValuePair> topGroups;

	ReportData(this.ageDistribution, this.bookingsByPayment, this.genders, this.topContacts, this.topGroups);

	factory ReportData.fromJson(String jsonStr) {
		final Map map = json.decode(jsonStr);
		return ReportData(
			_getReportData(map, AGE_DISTRIBUTION),
			_getReportData(map, BOOKINGS_BY_PAYMENT),
			_getReportData(map, GENDERS),
			_getReportData(map, TOP_CONTACTS),
			_getReportData(map, TOP_GROUPS)
		);
	}

	static List<KeyValuePair> _getReportData(Map map, String key) {
		final List keyMap = map[key];
		return keyMap
			.map((dynamic value) => KeyValuePair.fromMap(value))
			.toList(growable: false);
	}
}
