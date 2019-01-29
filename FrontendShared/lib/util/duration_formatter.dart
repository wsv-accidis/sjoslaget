abstract class DurationFormatter {
	static String formatCompact(Duration duration, [bool withMillis = false]) {
		int seconds = duration.inSeconds;
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

		if (withMillis) {
			if (seconds > 0) {
				result.write('${seconds}s ');
			}
			final int millis = duration.inMilliseconds % Duration.millisecondsPerSecond;
			result.write('${millis}ms');
		} else {
			result.write('${seconds}s');
		}

		return result.toString();
	}
	
	static String formatInSwedishAdaptive(Duration duration) {
		int millis = duration.inMilliseconds;
		final result = StringBuffer();
		bool includeSmallUnits = true;

		if (millis >= Duration.millisecondsPerDay) {
			final int days = (millis / Duration.millisecondsPerDay).floor();
			millis %= Duration.millisecondsPerDay;
			final String suffix = 1 == days ? '' : 'ar';
			result.write('$days dag$suffix');
			includeSmallUnits = false;
		}

		if (millis >= Duration.millisecondsPerHour) {
			if (result.isNotEmpty) {
				result.write(', ');
			}
			final int hours = (millis / Duration.millisecondsPerHour).floor();
			millis %= Duration.millisecondsPerHour;
			final String suffix = 1 == hours ? 'e' : 'ar';
			result.write('$hours timm$suffix');
			includeSmallUnits = false;
		}

		if (millis >= Duration.millisecondsPerMinute) {
			if (result.isNotEmpty) {
				result.write(', ');
			}
			final int mins = (millis / Duration.millisecondsPerMinute).floor();
			millis %= Duration.millisecondsPerMinute;
			final String suffix = 1 == mins ? '' : 'er';
			result.write('$mins minut$suffix');
		}

		if (includeSmallUnits) {
			if (millis >= Duration.millisecondsPerSecond) {
				if (result.isNotEmpty) {
					result.write(', ');
				}
				final int secs = (millis / Duration.millisecondsPerSecond).floor();
				millis %= Duration.millisecondsPerSecond;
				final String suffix = 1 == secs ? '' : 'er';
				result.write('$secs sekund$suffix');
			}

			if (millis > 0) {
				if (result.isNotEmpty) {
					result.write(', ');
				}
				result.write('$millis ms');
			}
		}

		return result.toString();
	}
}
