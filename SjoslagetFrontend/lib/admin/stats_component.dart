import 'dart:html' show querySelector, CanvasElement;
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:chartjs/chartjs.dart';

import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../client/report_repository.dart';
import '../model/cruise_cabin.dart';
import '../model/report_data.dart';
import '../model/report_summary.dart';
import '../model/string_pair.dart';

@Component(
	selector: 'sjoslaget-stats-app',
	templateUrl: 'stats_component.html',
	styleUrls: const ['stats_component.css'],
	providers: const <dynamic>[
		ClientFactory,
		CruiseRepository,
		ReportRepository
	],
	directives: const <dynamic>[CORE_DIRECTIVES]
)
class StatsComponent implements OnInit {
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final ReportRepository _reportRepository;

	Map<String, int> availability;
	List<CruiseCabin> cabins;
	ReportData current;
	ReportSummary summary;

	bool get hasCabins => null != cabins && null != availability;

	bool get hasTopContacts => null != current && current.topGroups.isNotEmpty;

	bool get hasTopGroups => null != current && current.topContacts.isNotEmpty;

	StatsComponent(this._clientFactory, this._cruiseRepository, this._reportRepository);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			availability = await _cruiseRepository.getCabinsAvailability(client);
			cabins = await _cruiseRepository.getActiveCruiseCabins(client);
			current = await _reportRepository.getCurrent(client);
			summary = await _reportRepository.getSummary(client);
		} catch (e) {
			print('Failed to load stats: ' + e.toString());
		}

		_createCharts();
	}

	int getBookedCount(CruiseCabin cabin) {
		if (null == availability || !availability.containsKey(cabin.id))
			return cabin.count;
		return cabin.count - availability[cabin.id];
	}

	void _createCharts() {
		if (null != summary && summary.labels.isNotEmpty) {
			_createSimpleLineChart(summary.bookingsCreated, 'Nya bokningar', 'rgba(2,97,163,0.6)', '#bookings-created-chart');
			_createSimpleLineChart(summary.bookingsTotal, 'Totalt antal bokningar', 'rgba(21,33,112,0.6)', '#bookings-total-chart');
			_createSimpleLineChart(summary.cabinsTotal, 'Totalt antal hytter', 'rgba(201,40,9,0.6)', '#cabins-total-chart');
			_createPaxAndCapacityChart('#pax-total-chart');
		}

		if (null != current) {
			_createGendersChart('#genders-chart');
		}
	}

	void _createGendersChart(String selector) {
		if (null == current || current.genders.isEmpty)
			return;

		int getGender(String g) {
			KeyValuePair pair = current.genders.firstWhere((KeyValuePair gender) => gender.key == g, orElse: null);
			return null != pair ? pair.value : 0;
		}

		var data = new LinearChartData(
			labels: ['Män', 'Övriga', 'Kvinnor'],
			datasets: <ChartDataSets>[
				new ChartDataSets(
					backgroundColor: <String>['rgb(119,158,203)', 'rgb(203,119,200)', 'rgb(203,122,119)'],
					data: <int>[getGender('m'), getGender('x'), getGender('f')]
				)
			]
		);

		var config = new ChartConfiguration(
			data: data,
			type: 'doughnut',
			options: new ChartOptions(
				legend: new ChartLegendOptions(position: 'bottom'),
				responsive: true,
				title: _createTitle('Kön')
			)
		);

		new Chart(querySelector(selector) as CanvasElement, config);
	}

	void _createLineChart(LinearChartData data, String label, String selector) {
		var config = new ChartConfiguration(
			data: data,
			type: 'line',
			options: new ChartOptions(
				legend: new ChartLegendOptions(display: false),
				responsive: true,
				title: _createTitle(label)
			)
		);

		new Chart(querySelector(selector) as CanvasElement, config);
	}

	void _createPaxAndCapacityChart(String selector) {
		var data = new LinearChartData(labels: summary.labels, datasets: <ChartDataSets>[
			new ChartDataSets(
				label: 'Totalt antal deltagare',
				backgroundColor: 'rgba(58,199,151,0.6)',
				data: summary.paxTotal),
			new ChartDataSets(
				label: 'Total bokad kapacitet',
				backgroundColor: 'rgba(21,112,98,0.2)',
				data: summary.capacityTotal
			)
		]);

		_createLineChart(data, 'Totalt antal deltagare/kapacitet', selector);
	}

	void _createSimpleLineChart(List<int> values, String label, String backgroundColor, String selector) {
		var data = new LinearChartData(labels: summary.labels, datasets: <ChartDataSets>[
			new ChartDataSets(
				backgroundColor: backgroundColor,
				data: values,
				label: label
			)
		]);

		_createLineChart(data, label, selector);
	}

	ChartTitleOptions _createTitle(String label) {
		return new ChartTitleOptions(display: true,
			fontColor: 'black',
			fontFamily: 'Carter One',
			fontSize: 20,
			padding: 15,
			text: label
		);
	}
}
