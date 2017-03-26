import 'package:quiver/strings.dart' as str show isNotEmpty;

import 'booking_pax.dart';

class BookingCabin {
	static const ID = 'Id';
	static const CABIN_TYPE_ID = 'TypeId';
	static const PAX = 'Pax';
	static const GROUP = 'Group';
	static const FIRSTNAME = 'FirstName';
	static const LASTNAME = 'LastName';
	static const GENDER = 'Gender';
	static const DOB = 'Dob';
	static const NATIONALITY = 'Nationality';
	static const YEARS = 'Years';

	final String id;
	final String cabinTypeId;
	final List<BookingPax> pax;

	BookingCabin(this.id, this.cabinTypeId, this.pax);

	Map<String, dynamic> toMap() {
		return {
			ID: id,
			CABIN_TYPE_ID: cabinTypeId,
			PAX: pax.where((p) => str.isNotEmpty(p.firstName)).map((p) =>
			{
				GROUP: p.group,
				FIRSTNAME: p.firstName,
				LASTNAME: p.lastName,
				GENDER: p.gender,
				DOB: p.dob,
				NATIONALITY: p.nationality,
				YEARS: p.years
			}).toList(growable: false)
		};
	}
}
