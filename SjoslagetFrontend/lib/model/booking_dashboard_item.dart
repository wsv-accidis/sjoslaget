import 'dart:convert';

class BookingDashboardItem {
	static const ID = 'Id';
	static const REFERENCE = 'Reference';
	static const FIRSTNAME = 'FirstName';
	static const LASTNAME = 'LastName';
	static const UPDATED = 'Updated';
	static const NUMBER_OF_CABINS = 'NumberOfCabins';
	static const NUMBER_OF_PAX = 'NumberOfPax';

	String id;
	String reference;
	String firstName;
	String lastName;
	String updated;
	int numberOfCabins;
	int numberOfPax;

	BookingDashboardItem(this.id, this.reference, this.firstName, this.lastName, this.updated, this.numberOfCabins, this.numberOfPax);

	factory BookingDashboardItem.fromMap(Map<String, dynamic> json) {
		return new BookingDashboardItem(
			json[ID],
			json[REFERENCE],
			json[FIRSTNAME],
			json[LASTNAME],
			json[UPDATED],
			json[NUMBER_OF_CABINS],
			json[NUMBER_OF_PAX]
		);
	}
}
