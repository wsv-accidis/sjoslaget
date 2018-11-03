import 'package:angular/angular.dart';

@Component(
	selector: 'spinner-widget',
	styleUrls: ['spinner_widget.css'],
	template: '''
	<div class="spinner-container">
		<div class="spinner-circle0"></div>
		<div class="spinner-circle1"></div>
	</div>'''
)
class SpinnerWidget {
}
