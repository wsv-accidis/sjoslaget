import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import 'hello_dialog/hello_dialog.dart';

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives, HelloDialog],
  providers: const [materialProviders],
)
class AppComponent {
  // Nothing here yet. All logic is in HelloDialog.
}
