class BookingDashboardItem {
	static const ID = 'Id';
	static const REFERENCE = 'Reference';
	static const FIRSTNAME = 'FirstName';
	static const LASTNAME = 'LastName';
	static const CREATED = 'Created';
	static const UPDATED = 'Updated';
	static const NUMBER_OF_CABINS = 'NumberOfCabins';
	static const NUMBER_OF_PAX = 'NumberOfPax';

	Duration _sinceUpdated;

	final String id;
	final String reference;
	final String firstName;
	final String lastName;
	final DateTime created;
	final DateTime updated;
	final int numberOfCabins;
	final int numberOfPax;

	String get sinceUpdated {
		if (null == _sinceUpdated)
			return '';

		int seconds = _sinceUpdated.inSeconds;
		final result = new StringBuffer();

		if (seconds >= Duration.SECONDS_PER_DAY) {
			final days = (seconds / Duration.SECONDS_PER_DAY).floor();
			seconds %= Duration.SECONDS_PER_DAY;
			result.write('${days}d ');
		}

		if (seconds >= Duration.SECONDS_PER_HOUR) {
			final hours = (seconds / Duration.SECONDS_PER_HOUR).floor();
			seconds %= Duration.SECONDS_PER_HOUR;
			result.write('${hours}h ');
		}

		if (seconds >= Duration.SECONDS_PER_MINUTE) {
			final mins = (seconds / Duration.SECONDS_PER_MINUTE).floor();
			seconds %= Duration.SECONDS_PER_MINUTE;
			result.write('${mins}m ');
		}

		result.write('${seconds}s');
		return result.toString();
	}

	BookingDashboardItem(this.id, this.reference, this.firstName, this.lastName, this.created, this.updated, this.numberOfCabins, this.numberOfPax);

	factory BookingDashboardItem.fromMap(Map<String, dynamic> json) {
		return new BookingDashboardItem(
			json[ID],
			json[REFERENCE],
			json[FIRSTNAME],
			json[LASTNAME],
			DateTime.parse(json[CREATED]),
			DateTime.parse(json[UPDATED]),
			json[NUMBER_OF_CABINS],
			json[NUMBER_OF_PAX]
		);
	}

	void update(DateTime now) {
		_sinceUpdated = now.difference(updated);
	}
}
