import 'dart:html' show querySelector, CanvasElement;
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:chartjs/chartjs.dart';

import '../client/client_factory.dart';
import '../client/report_repository.dart';
import '../model/report_summary.dart';

@Component(
	selector: 'sjoslaget-stats-app',
	templateUrl: 'stats_component.html',
	styleUrls: const ['stats_component.css'],
	providers: const <dynamic>[
		ClientFactory,
		ReportRepository
	],
	directives: const <dynamic>[]
)
class StatsComponent implements OnInit {
	final ClientFactory _clientFactory;
	final ReportRepository _reportRepository;

	ReportSummary _summary;

	StatsComponent(this._clientFactory, this._reportRepository);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			_summary = await _reportRepository.getSummary(client);
		} catch (e) {
			print('Failed to load stats: ' + e.toString());
		}

		if (null != _summary && _summary.labels.isNotEmpty) {
			createCharts();
		} else {
			// TODO Show some kind of placeholder in case no data exists
		}
	}

	void createCharts() {
		createSimpleLineChart(_summary.bookingsCreated, 'Nya bokningar', 'rgba(2,97,163,0.6)', '#bookings-created-chart');
		createSimpleLineChart(_summary.bookingsTotal, 'Totalt antal bokningar', 'rgba(21,33,112,0.6)', '#bookings-total-chart');
		createSimpleLineChart(_summary.cabinsTotal, 'Totalt antal hytter', 'rgba(201,40,9,0.6)', '#cabins-total-chart');
		createPaxAndCapacityChart('#pax-total-chart');
	}

	void createPaxAndCapacityChart(String selector) {
		var data = new LinearChartData(labels: _summary.labels, datasets: <ChartDataSets>[
			new ChartDataSets(
				label: 'Totalt antal deltagare',
				backgroundColor: 'rgba(58,199,151,0.6)',
				data: _summary.paxTotal),
			new ChartDataSets(
				label: 'Total bokad kapacitet',
				backgroundColor: 'rgba(21,112,98,0.2)',
				data: _summary.capacityTotal
			)
		]);

		createLineChart(data, 'Totalt antal deltagare/kapacitet', selector);
	}

	void createSimpleLineChart(List<int> values, String label, String backgroundColor, String selector) {
		var data = new LinearChartData(labels: _summary.labels, datasets: <ChartDataSets>[
			new ChartDataSets(
				label: label,
				backgroundColor: backgroundColor,
				data: values)
		]);

		createLineChart(data, label, selector);
	}

	void createLineChart(LinearChartData data, String label, String selector) {
		var config = new ChartConfiguration(
			type: 'line',
			data: data,
			options: new ChartOptions(
				legend: new ChartLegendOptions(display: false),
				responsive: true,
				title: new ChartTitleOptions(display: true, text: label, fontFamily: 'Carter One', fontSize: 20, padding: 15)
			)
		);

		new Chart(querySelector(selector) as CanvasElement, config);
	}
}
