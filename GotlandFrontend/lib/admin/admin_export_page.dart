import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/client.dart';

import '../client/client_factory.dart';
import '../widgets/components.dart';
import 'admin_routes.dart';

@Component(
    selector: 'admin-export-page',
    templateUrl: 'admin_export_page.html',
    styleUrls: ['../content/content_styles.css', 'admin_styles.css'],
    directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, gotlandMaterialDirectives],
    exports: <dynamic>[AdminRoutes])
class AdminExportPage {
  final String _apiRoot;
  final ClientFactory _clientFactory;

  bool isDownloading = false;

  AdminExportPage(@Inject(GOTLAND_API_ROOT) this._apiRoot, this._clientFactory);

  Future<void> doExportBookings() async {
    await doExport('$_apiRoot/export/bookings');
  }

  Future<void> doExportDayBookings() async {
    await doExport('$_apiRoot/export/daybookings');
  }

  Future<void> doExport(String uri) async {
    if (isDownloading) return;

    isDownloading = true;
    try {
      final client = _clientFactory.getClient();
      final response = await client.get(uri);

      HttpStatus.throwIfNotSuccessful(response);

      final fileName = _getFileName(response.headers['content-disposition']);
      final blob = Blob(<dynamic>[response.bodyBytes]);
      final link = AnchorElement(href: Url.createObjectUrlFromBlob(blob));
      link.download = fileName;
      link.click();
    } catch (e) {
      print('Failed to export: ${e.toString()}');
    } finally {
      isDownloading = false;
    }
  }

  static String _getFileName(String contentDisp) {
    final regEx = RegExp(r'^attachment; filename=(.+)$');
    if (null != contentDisp && regEx.hasMatch(contentDisp)) {
      return regEx.firstMatch(contentDisp).group(1);
    } else {
      return 'Export.xlsx';
    }
  }
}
