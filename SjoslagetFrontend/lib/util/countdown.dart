class Countdown {
	final DateTime _countdownTo;

	int get inMilliseconds => (_countdownTo.difference(DateTime.now())).inMilliseconds;

	int get inHours => inMilliseconds ~/ Duration.millisecondsPerHour;

	int get inMinutes => inMilliseconds ~/ Duration.millisecondsPerMinute;

	int get inSeconds => inMilliseconds ~/ Duration.millisecondsPerSecond;

	bool get isElapsed => inMilliseconds < 0;

	Countdown(this._countdownTo);

	@override
	String toString() {
		final String twoDigitMinutes = inMinutes.remainder(Duration.minutesPerHour).toString().padLeft(2, '0');
		final String twoDigitSeconds = inSeconds.remainder(Duration.secondsPerMinute).toString().padLeft(2, '0');
		final String oneDigitMs = (inMilliseconds.remainder(Duration.millisecondsPerSecond) ~/ 100).toString();
		return '$inHours:$twoDigitMinutes:$twoDigitSeconds.$oneDigitMs';
	}
}
