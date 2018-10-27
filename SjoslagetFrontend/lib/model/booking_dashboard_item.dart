import 'json_field.dart';

class BookingDashboardItem {
	Duration _sinceUpdated;

	final String id;
	final String reference;
	final String firstName;
	final String lastName;
	final DateTime created;
	final DateTime updated;
	final int numberOfCabins;
	final int numberOfPax;

	BookingDashboardItem(this.id, this.reference, this.firstName, this.lastName, this.created, this.updated, this.numberOfCabins, this.numberOfPax);

	factory BookingDashboardItem.fromMap(Map<String, dynamic> json) =>
		BookingDashboardItem(
			json[ID],
			json[REFERENCE],
			json[FIRSTNAME],
			json[LASTNAME],
			DateTime.parse(json[CREATED]),
			DateTime.parse(json[UPDATED]),
			json[NUMBER_OF_CABINS],
			json[NUMBER_OF_PAX]
		);

	String get sinceUpdated {
		if (null == _sinceUpdated)
			return '';

		int seconds = _sinceUpdated.inSeconds;
		final result = StringBuffer();

		if (seconds >= Duration.secondsPerDay) {
			final days = (seconds / Duration.secondsPerDay).floor();
			seconds %= Duration.secondsPerDay;
			result.write('${days}d ');
		}

		if (seconds >= Duration.secondsPerHour) {
			final hours = (seconds / Duration.secondsPerHour).floor();
			seconds %= Duration.secondsPerHour;
			result.write('${hours}h ');
		}

		if (seconds >= Duration.secondsPerMinute) {
			final mins = (seconds / Duration.secondsPerMinute).floor();
			seconds %= Duration.secondsPerMinute;
			result.write('${mins}m ');
		}

		result.write('${seconds}s');
		return result.toString();
	}

	void update(DateTime now) {
		_sinceUpdated = now.difference(updated);
	}
}
