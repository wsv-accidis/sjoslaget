import 'dart:convert';
import 'json_field.dart';

import 'string_pair.dart';

class ReportData {
	final List<KeyValuePair> genders;
	final List<KeyValuePair> topContacts;
	final List<KeyValuePair> topGroups;

	ReportData(this.genders, this.topContacts, this.topGroups);

	factory ReportData.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new ReportData(
			getReportData(map, GENDERS),
			getReportData(map, TOP_CONTACTS),
			getReportData(map, TOP_GROUPS)
		);
	}

	static List<KeyValuePair> getReportData(Map<String, dynamic> map, String key) =>
		map[key].map((Map<String, dynamic> value) => new KeyValuePair.fromMap(value)).toList(growable: false);
}
