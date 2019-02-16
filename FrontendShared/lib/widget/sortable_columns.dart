import 'dart:async';
import 'dart:collection';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

class SortableState {
	final String column;
	final bool desc;

	SortableState(this.column, this.desc);
}

@Directive(selector: '[sortableColumns]')
class SortableColumns {
	final _headers = HashMap<String, SortableColumnHeader>();
	final _onSortChange = StreamController<SortableState>.broadcast();
	SortableState _state = SortableState('', false);

	@Output()
	Stream get onSortChange => _onSortChange.stream;

	@Input()
	set sortColumn(String column) {
		if (_state.column != column) {
			_state = SortableState(column, _state.desc);
			_refreshState();
		}
	}

	@Input()
	set sortDesc(bool desc) {
		if (_state.desc != desc) {
			_state = SortableState(_state.column, desc);
			_refreshState();
		}
	}

	void change(String column, bool desc) {
		_state = SortableState(column, desc);
		_refreshState();
	}

	void register(SortableColumnHeader header) {
		print('Registered sortable column \"${header.key}\".');
		_headers[header.key] = header;
		_applyTo(header);
	}

	void _refreshState() {
		_onSortChange.add(_state);
		_headers.values.forEach(_applyTo);
	}

	void _applyTo(SortableColumnHeader header) {
		if (_state.column == header.key)
			header.mode = _state.desc ? SortableColumnHeader.DESC : SortableColumnHeader.ASC;
		else
			header.mode = SortableColumnHeader.OFF;
	}
}

@Component(
	selector: 'sortable-column-header',
	template: '''
		<div style="display: inline-flex; align-items: center">
			<a href="javascript:" (click)="toggle()">{{ title }}</a>
			<material-icon *ngIf="mode == 'asc'" icon="arrow_downward"></material-icon>
			<material-icon *ngIf="mode == 'desc'" icon="arrow_upward"></material-icon>
		</div>''',
	directives: <dynamic>[coreDirectives, MaterialIconComponent]
)
class SortableColumnHeader implements OnInit {
	final SortableColumns _sortableColumns;

	static const String ASC = 'asc';
	static const String DESC = 'desc';
	static const String OFF = '';

	SortableColumnHeader(@Host() this._sortableColumns);

	@override
	void ngOnInit() {
		_sortableColumns.register(this);
	}

	@Input()
	String key = '';

	@Input()
	String mode = OFF;

	@Input()
	String title = '';

	void toggle() {
		mode = ASC == mode ? DESC : ASC;
		_sortableColumns.change(key, mode == DESC);
	}
}
