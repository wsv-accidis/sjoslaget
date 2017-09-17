import 'dart:async';
import 'dart:html';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/client_factory.dart';
import '../client/http_status.dart';
import '../util/true_false.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-export-page',
	templateUrl: 'admin_export_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css'],
	directives: const<dynamic>[ROUTER_DIRECTIVES, materialDirectives, SpinnerWidget],
	providers: const<dynamic>[materialProviders]
)
class AdminExportPage {
	final ClientFactory _clientFactory;
	final String _apiRoot;

	bool isDownloading = false;
	String onlyFullyPaid = TRUE;

	AdminExportPage(@Inject(SJOSLAGET_API_ROOT) this._apiRoot, this._clientFactory);

	Future<Null> doExport() async {
		if(isDownloading)
			return;

		isDownloading = true;
		try {
			final client = _clientFactory.getClient();
			final response = await client.get(_apiRoot
				+ '/export/excel'
				+ '?onlyFullyPaid=' + (TRUE == onlyFullyPaid ? TRUE : FALSE)
			);

			HttpStatus.throwIfNotSuccessful(response);

			final fileName = _getFileName(response.headers['content-disposition']);
			final blob = new Blob(<dynamic>[response.bodyBytes]);
			final link = new AnchorElement(href: Url.createObjectUrlFromBlob(blob));
			link.download = fileName;
			link.click();
		} catch (e) {
			print('Failed to export: ' + e.toString());
		} finally {
			isDownloading = false;
		}
	}

	static String _getFileName(String contentDisp) {
		final regEx = new RegExp(r'^attachment; filename=(.+)$');
		if (null != contentDisp && regEx.hasMatch(contentDisp)) {
			return regEx.firstMatch(contentDisp).group(1);
		} else {
			return 'Export.xlsx';
		}
	}
}
