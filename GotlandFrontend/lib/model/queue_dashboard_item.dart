import 'package:frontend_shared/util.dart' show DurationFormatter, ValueConverter;
import 'package:quiver/strings.dart' show isNotEmpty;

import 'json_field.dart';

class QueueDashboardItem {
	Duration _timeSinceCreated;

	final String firstName;
	final String lastName;
	final String teamName;
	final int teamSize;
	final DateTime created;
	final DateTime queued;
	final int queueNo;
	final int queueLatencyMs;
	final String reference;

	QueueDashboardItem(this.firstName, this.lastName, this.teamName, this.teamSize, this.created, this.queued, this.queueNo, this.queueLatencyMs, this.reference);

	factory QueueDashboardItem.fromMap(Map<String, dynamic> json) =>
		QueueDashboardItem(
			json[FIRSTNAME],
			json[LASTNAME],
			json[TEAM_NAME],
			json[TEAM_SIZE],
			DateTime.parse(json[CREATED]),
			ValueConverter.parseDateTime(json[QUEUED]),
			json[QUEUE_NO],
			json[QUEUE_LATENCY_MS],
			json[REFERENCE]
		);

	bool get hasBeenQueued => queueNo >= 0;

	bool get hasReference => isNotEmpty(reference);

	String get timeInCountdown {
		Duration duration;
		if (hasBeenQueued) {
			duration = queued.difference(created);
		} else if (null != _timeSinceCreated) {
			duration = _timeSinceCreated;
		} else {
			return '';
		}

		return DurationFormatter.formatCompact(duration);
	}

	String get queueLatency {
		if (queueLatencyMs < 0)
			return '';

		return DurationFormatter.formatCompact(Duration(milliseconds: queueLatencyMs), true);
	}

	void update(DateTime now) {
		_timeSinceCreated = now.difference(created);
	}
}
