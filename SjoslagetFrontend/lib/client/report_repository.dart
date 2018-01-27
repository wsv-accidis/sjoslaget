import 'dart:async';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import 'client_factory.dart' show SJOSLAGET_API_ROOT;
import '../model/report_summary.dart';

@Injectable()
class ReportRepository {
	final String _apiRoot;

	ReportRepository(@Inject(SJOSLAGET_API_ROOT) this._apiRoot);

	Future<ReportSummary> getSummary(Client client) async {
		Response response;
		try {
			response = await client.get(_apiRoot + '/reporting/summary');
		} catch (e) {
			throw new IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return new ReportSummary.fromJson(response.body);
	}
}
