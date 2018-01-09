import 'dart:convert';

import 'json_field.dart';

class BookingDetails {
	String firstName;
	String lastName;
	String phoneNo;
	String email;
	String teamName;
	int teamSize;

	BookingDetails(this.firstName, this.lastName, this.phoneNo, this.email, this.teamName, this.teamSize);

	String toJson() {
		return JSON.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			EMAIL: email,
			TEAM_NAME: teamName,
			TEAM_SIZE: teamSize
		});
	}
}
