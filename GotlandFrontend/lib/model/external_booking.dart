import 'dart:convert';

import 'json_field.dart';

class ExternalBooking {
	ExternalBooking(this.firstName, this.lastName, this.phoneNo, this.dob, this.specialRequest, this.isRindiMember, this.dayFriday, this.daySaturday);

	final String firstName;
	final String lastName;
	final String phoneNo;
	final String dob;
	final String specialRequest;
	final bool isRindiMember;
	final bool dayFriday;
	final bool daySaturday;

	String toJson() =>
		json.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			DOB: dob,
			SPECIAL_REQUEST: specialRequest,
			IS_RINDI_MEMBER: isRindiMember,
			DAY_FRIDAY: dayFriday,
			DAY_SATURDAY: daySaturday
		});
}
