import 'dart:convert';

class BookingDetails {
	static const EMAIL = 'email';
	static const FIRSTNAME = 'firstName';
	static const LASTNAME = 'lastName';
	static const LUNCH = 'lunch';
	static const PHONE_NO = 'phoneNo';

	String firstName;
	String lastName;
	String phoneNo;
	String email;
	String lunch;

	BookingDetails(this.firstName, this.lastName, this.phoneNo, this.email, this.lunch);

	String toJson() {
		return JSON.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			EMAIL: email,
			LUNCH: lunch
		});
	}

	BookingDetails.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		firstName = map[FIRSTNAME];
		lastName = map[LASTNAME];
		phoneNo = map[PHONE_NO];
		email = map[EMAIL];
		lunch = map[LUNCH];
	}
}
