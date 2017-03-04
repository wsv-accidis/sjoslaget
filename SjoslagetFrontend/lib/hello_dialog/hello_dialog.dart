import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

@Component(
  selector: 'hello-dialog',
  styleUrls: const ['hello_dialog.css'],
  templateUrl: 'hello_dialog.html',
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
class HelloDialog {
  /// Modal component that hosts the inner MaterialDialog in a centered overlay.
  @ViewChild('wrappingModal')
  ModalComponent wrappingModal;

  @Input()
  String username = "";

  @Input()
  String password = "";

  final authorizationEndpoint = Uri.parse("/api/token");

  Future<oauth2.Client> getClient(String username, String password) async {
    return await oauth2.resourceOwnerPasswordGrant(authorizationEndpoint, username, password);
  }

  Future<Null> authenticate() async {
    oauth2.Client client = await getClient(username, password);
    open();
  }

  /// Opens the dialog.
  void open() {
    wrappingModal.open();
  }
}
