import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

@Component(
	selector: 'modal-dialog',
	templateUrl: 'modal_dialog.html',
	directives: <dynamic>[coreDirectives, MaterialButtonComponent, MaterialDialogComponent, ModalComponent],
	providers: <dynamic>[materialProviders]
)
class ModalDialog {
	Completer _completer;

	@ViewChild('wrappingModal')
	ModalComponent wrappingModal;

	@Input()
	String title = '';

	@Input()
	String message = '';

	@Input()
	String action = '';

	bool get hasAction => isNotEmpty(action);

	void close() {
		wrappingModal.close();
		if (null != _completer)
			_completer.complete(false);
	}

	void doAction() {
		wrappingModal.close();
		if (null != _completer)
			_completer.complete(true);
	}

	void open() {
		_completer = null;
		wrappingModal.open();
	}

	Future<bool> openAsync() {
		_completer = Completer<bool>();
		wrappingModal.open();
		return _completer.future;
	}
}
