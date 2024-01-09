import 'dart:convert';

import 'json_field.dart';

class BookingDetails {
	String firstName;
	String lastName;
	String phoneNo;
	String email;
	String groupName;
	String teamName;
	int teamSize;

	BookingDetails(this.firstName, this.lastName, this.phoneNo, this.email, this.groupName, this.teamName, this.teamSize);

	String toJson() =>
		json.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			EMAIL: email,
			GROUP_NAME: groupName,
			TEAM_NAME: teamName,
			TEAM_SIZE: teamSize
		});
}
