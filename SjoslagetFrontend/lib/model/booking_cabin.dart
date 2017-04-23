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

	factory BookingCabin.fromMap(Map<String, dynamic> map) {
		List<BookingPax> pax = map[PAX].map((Map<String, dynamic> value) =>
		new BookingPax(
			value[GROUP],
			value[FIRSTNAME],
			value[LASTNAME],
			value[GENDER],
			value[DOB],
			value[NATIONALITY],
			value[YEARS])).toList(growable: false);

		return new BookingCabin(map[ID], map[CABIN_TYPE_ID], pax);
	}

	Map<String, dynamic> toMap() {
		return <String, dynamic>{
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
