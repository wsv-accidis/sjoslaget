import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/client.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' as str show isBlank, isNotEmpty;

import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/sub_cruise.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

const String TRUE = 'true';
const String FALSE = 'false';

@Component(
    selector: 'admin-export-page',
    templateUrl: 'admin_export_page.html',
    styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_export_page.css'],
    directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, sjoslagetMaterialDirectives, SpinnerWidget],
    exports: <dynamic>[AdminRoutes])
class AdminExportPage implements OnInit {
  final String _apiRoot;
  final ClientFactory _clientFactory;
  final CruiseRepository _cruiseRepository;

  bool isDownloading = false;
  String onlyFullyPaid = TRUE;
  String subCruise = 'A';
  List<SubCruise> subCruises;
  String updatedSince;
  DateTime updatedSinceDate;
  String updatedSinceError;

  AdminExportPage(@Inject(SJOSLAGET_API_ROOT) this._apiRoot, this._clientFactory, this._cruiseRepository);

  bool get canDownload => !isDownloading && !hasUpdatedSinceError;

  bool get hasUpdatedSinceError => str.isNotEmpty(updatedSinceError);

  bool get isLoaded => null != subCruises;

  Future<void> doExport() async {
    if (!canDownload) return;

    isDownloading = true;
    try {
      final client = _clientFactory.getClient();
      final response = await client.get('$_apiRoot/export/excel?onlyFullyPaid=${TRUE == onlyFullyPaid ? TRUE : FALSE}' +
          '&subCruise=$subCruise&updatedSince=${null != updatedSinceDate ? DateTimeFormatter.formatShort(updatedSinceDate) : ''}');

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

  @override
  Future<void> ngOnInit() async {
    try {
      final client = _clientFactory.getClient();
      subCruises = await _cruiseRepository.getActiveSubCruises(client);
    } catch (e) {
      print('Failed to get active subcruises: ${e.toString()}');
    }
  }

  void validate() {
    updatedSinceError = null;

    if (str.isBlank(updatedSince)) {
      updatedSinceDate = null;
      return;
    }
    try {
      updatedSinceDate = DateTime.parse(updatedSince);
    } catch (e) {
      updatedSinceDate = null;
      updatedSinceError = 'Ange korrekt datum.';
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
