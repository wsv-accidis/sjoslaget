import 'dart:async';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import '../model/report_data.dart';
import '../model/report_summary.dart';
import 'client_factory.dart' show SJOSLAGET_API_ROOT;

@Injectable()
class ReportRepository {
	final String _apiRoot;

	ReportRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<ReportData> getCurrent(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/reporting/current');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return ReportData.fromJson(response.body);
	}

	Future<ReportSummary> getSummary(Client client) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/reporting/summary');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return ReportSummary.fromJson(response.body);
	}
}
