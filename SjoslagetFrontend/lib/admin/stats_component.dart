import 'dart:html';
import 'dart:math' as math;

import 'package:angular/angular.dart';
import 'package:chartjs/chartjs.dart';

import '../client/client_factory.dart';

@Component(
	selector: 'sjoslaget-stats-app',
	templateUrl: 'stats_component.html',
	providers: const <dynamic>[
		ClientFactory,
	],
	directives: const <dynamic>[]
)
class StatsComponent implements OnInit {
	final ClientFactory _clientFactory;

	StatsComponent(this._clientFactory);

	void ngOnInit() {
		var rnd = new math.Random();
		var months = <String>['January', 'February', 'March', 'April', 'May', 'June'];

		var data = new LinearChartData(labels: months, datasets: <ChartDataSets>[
			new ChartDataSets(
				label: 'My First dataset',
				backgroundColor: 'rgba(220,220,220,0.2)',
				data: months.map((_) => rnd.nextInt(100)).toList()),
			new ChartDataSets(
				label: 'My Second dataset',
				backgroundColor: 'rgba(151,187,205,0.2)',
				data: months.map((_) => rnd.nextInt(100)).toList())
		]);

		var config = new ChartConfiguration(
			type: 'line', data: data, options: new ChartOptions(responsive: true));

		new Chart(querySelector('#canvas') as CanvasElement, config);
	}
}
