import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import '../hello_dialog/hello_dialog.dart';

@Component(
  selector: 'login-page',
  templateUrl: 'login_page.html',
  directives: const [materialDirectives, HelloDialog],
  providers: const [materialProviders],
)
class LoginPage {
}
