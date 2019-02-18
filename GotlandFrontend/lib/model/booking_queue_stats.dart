import 'dart:convert';

import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class BookingQueueStats {
	final int aheadInQueue;
	final int queueLatencyMs;
	final int queueNo;
	final int teamSize;

	BookingQueueStats(this.aheadInQueue, this.queueLatencyMs, this.queueNo, this.teamSize);

	factory BookingQueueStats.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return BookingQueueStats(map[AHEAD_IN_QUEUE], map[QUEUE_LATENCY_MS], map[QUEUE_NO], map[TEAM_SIZE]);
	}

	bool get isEmpty => 0 == teamSize || queueLatencyMs < 0;

	// Very arbitrarily assume that within the first 200 or so pax everyone will get what they want
	bool get isEarlyBooking => aheadInQueue < 200;

	// Even more arbitrarily assume that we will run out of the more popular types after this point
	bool get isLateBooking => aheadInQueue > 400;

	String get queueLatency => DurationFormatter.formatInSwedishAdaptive(Duration(milliseconds: queueLatencyMs));
}
