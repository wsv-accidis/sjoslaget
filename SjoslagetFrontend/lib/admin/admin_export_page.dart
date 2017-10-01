import 'dart:async';
import 'dart:html';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:quiver/strings.dart' as str show isBlank, isNotEmpty;

import '../client/client_factory.dart';
import '../client/http_status.dart';
import '../util/true_false.dart';
import '../util/datetime_formatter.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-export-page',
	templateUrl: 'admin_export_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css', 'admin_export_page.css'],
	directives: const<dynamic>[ROUTER_DIRECTIVES, materialDirectives, SpinnerWidget],
	providers: const<dynamic>[materialProviders]
)
class AdminExportPage {
	final ClientFactory _clientFactory;
	final String _apiRoot;

	bool isDownloading = false;
	String onlyFullyPaid = TRUE;
	String updatedSince;
	DateTime updatedSinceDate;
	String updatedSinceError;

	bool get canDownload => !isDownloading && !hasUpdatedSinceError;

	bool get hasUpdatedSinceError => str.isNotEmpty(updatedSinceError);

	AdminExportPage(@Inject(SJOSLAGET_API_ROOT) this._apiRoot, this._clientFactory);

	Future<Null> doExport() async {
		if(!canDownload)
			return;

		isDownloading = true;
		try {
			final client = _clientFactory.getClient();
			final response = await client.get(_apiRoot
				+ '/export/excel'
				+ '?onlyFullyPaid=' + (TRUE == onlyFullyPaid ? TRUE : FALSE)
				+ '&updatedSince=' + (null != updatedSinceDate ? DateTimeFormatter.formatShort(updatedSinceDate) : '')
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

	void validate() {
		updatedSinceError = null;

		if(str.isBlank(updatedSince)) {
			updatedSinceDate = null;
			return;
		}
		try {
			updatedSinceDate = DateTime.parse(updatedSince);
		} catch(e) {
			updatedSinceDate = null;
			updatedSinceError = 'Ange korrekt datum.';
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
