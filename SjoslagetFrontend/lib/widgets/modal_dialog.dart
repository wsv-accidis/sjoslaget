import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

@Component(
	selector: 'modal-dialog',
	templateUrl: 'modal_dialog.html',
	directives: const <dynamic>[materialDirectives],
	providers: const <dynamic>[materialProviders]
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
		_completer = new Completer<bool>();
		wrappingModal.open();
		return _completer.future;
	}
}
