import 'json_field.dart';

class AllocationListItem {
	final String cabinId;
	final String reference;
	final String teamName;
	final String note;
	final int numberOfPax;
	final int totalPax;

	AllocationListItem(this.cabinId, this.reference, this.teamName, this.note, this.numberOfPax, this.totalPax);

	factory AllocationListItem.fromMap(Map<String, dynamic> json) =>
		AllocationListItem(
			json[CABIN_ID],
			json[REFERENCE],
			json[TEAM_NAME],
			json[NOTE],
			json[NUMBER_OF_PAX],
			json[TOTAL_PAX],
		);
}
