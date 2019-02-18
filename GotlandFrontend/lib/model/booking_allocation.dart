import 'json_field.dart';

class BookingAllocation {
	final String cabinId;
	final int noOfPax;
	final String note;

	BookingAllocation(this.cabinId, this.noOfPax, this.note);

	factory BookingAllocation.fromMap(Map<String, dynamic> json) =>
		BookingAllocation(
			json[CABIN_ID],
			json[NUMBER_OF_PAX],
			json[NOTE]
		);

	Map<String, dynamic> toMap() =>
		<String, dynamic>{
			CABIN_ID: cabinId,
			NUMBER_OF_PAX: noOfPax,
			NOTE: note
		};
}
