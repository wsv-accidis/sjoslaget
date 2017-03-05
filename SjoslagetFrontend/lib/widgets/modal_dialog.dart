import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

@Component(
	selector: 'modal-dialog',
	templateUrl: 'modal_dialog.html',
	directives: const [materialDirectives],
	providers: const [materialProviders]
)
class ModalDialog {
	@ViewChild('wrappingModal')
	ModalComponent wrappingModal;

	@Input()
	String title = '';

	@Input()
	String message = '';

	void open() {
		wrappingModal.open();
	}
}
