import 'dart:async';
import 'dart:html' show querySelector;

import 'package:angular/angular.dart';
import 'package:chartjs/chartjs.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../client/report_repository.dart';
import '../model/cruise_cabin.dart';
import '../model/cruise_product.dart';
import '../model/report_data.dart';
import '../model/report_summary.dart';
import '../model/string_pair.dart';
import '../model/sub_cruise.dart';

@Component(
    selector: 'sjoslaget-stats-app',
    templateUrl: 'stats_component.html',
    styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'stats_component.css'],
    providers: <dynamic>[ClientFactory, CruiseRepository, ReportRepository],
    directives: <dynamic>[coreDirectives])
class StatsComponent implements OnInit {
  static const int NOT_LIMITED = -1;
  static final NumberFormat _fpNumFormat = NumberFormat('0.00');

  final ClientFactory _clientFactory;
  final CruiseRepository _cruiseRepository;
  final ReportRepository _reportRepository;

  Map<String, int> cabinsAvailability;
  List<CruiseCabin> cabins;
  ReportData current;
  Map<String, int> productsQuantity;
  List<CruiseProduct> products;
  List<SubCruise> subCruises;
  ReportSummary summary;

  StatsComponent(this._clientFactory, this._cruiseRepository, this._reportRepository);

  bool get hasCabins => null != cabins && null != cabinsAvailability;

  bool get hasProducts => null != products && null != productsQuantity;

  bool get hasTopContacts => null != current && current.topGroups.isNotEmpty;

  bool get hasTopGroups => null != current && current.topContacts.isNotEmpty;

  @override
  Future<void> ngOnInit() async {
    try {
      final client = _clientFactory.getClient();
      cabinsAvailability = await _cruiseRepository.getCabinsAvailability(client);
      cabins = await _cruiseRepository.getActiveCruiseCabins(client);
      subCruises = await _cruiseRepository.getActiveSubCruises(client);

      products = await _cruiseRepository.getActiveCruiseProducts(client);
      productsQuantity = await _cruiseRepository.getProductsQuantity(client);

      current = await _reportRepository.getCurrent(client);
      summary = await _reportRepository.getSummary(client);
    } catch (e) {
      print('Failed to load stats: ${e.toString()}');
      rethrow;
    }

    _createCharts();
  }

  int getBookedCount(CruiseCabin cabin) {
    if (null == cabinsAvailability || !cabinsAvailability.containsKey(cabin.id)) return cabin.count;
    return cabin.count - cabinsAvailability[cabin.id];
  }

  int getBookedPercent(CruiseCabin cabin) => 100 * getBookedCount(cabin) ~/ cabin.count;

  List<CruiseCabin> getCabins(String subCruise) => cabins.where((c) => c.subCruise == subCruise).toList(growable: false);

  int getProductBookedCount(CruiseProduct prod) {
    if (null == productsQuantity || !productsQuantity.containsKey(prod.id)) return 0;
    return productsQuantity[prod.id];
  }

  String getProductCount(CruiseProduct prod) {
    if (NOT_LIMITED == prod.count) return 'Obegr.';
    return prod.count.toString();
  }

  String getProductRatio(CruiseProduct prod) {
    if (null == summary || summary.paxTotal.isEmpty) {
      return '-';
    }

    final int currentPaxTotal = summary.paxTotal.last;
    return _fpNumFormat.format(getProductBookedCount(prod) / currentPaxTotal);
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
      _createAgeChart('#ages-chart');
      _createPaymentsChart('#payment-chart');
    }
  }

  void _createAgeChart(String selector) {
    if (current.ageDistribution.isEmpty) return;

    final data = LinearChartData(labels: current.ageDistribution.map((pair) => pair.key).toList(growable: false), datasets: <ChartDataSets>[
      ChartDataSets(backgroundColor: 'rgba(21,33,112,0.8)', data: current.ageDistribution.map((pair) => pair.value).toList(growable: false))
    ]);

    final config = ChartConfiguration(
        data: data, type: 'bar', options: ChartOptions(legend: ChartLegendOptions(display: false), responsive: true, title: _createTitle('Födelseår')));

    Chart(querySelector(selector), config);
  }

  void _createDoughnutChart(LinearChartData data, String label, String selector) {
    final config = ChartConfiguration(
        data: data, type: 'doughnut', options: ChartOptions(legend: ChartLegendOptions(position: 'bottom'), responsive: true, title: _createTitle(label)));

    Chart(querySelector(selector), config);
  }

  void _createGendersChart(String selector) {
    if (current.genders.isEmpty) return;

    final data = LinearChartData(labels: <String>[
      'Män',
      'Övriga',
      'Kvinnor'
    ], datasets: <ChartDataSets>[
      ChartDataSets(
          backgroundColor: <String>['rgb(119,158,203)', 'rgb(203,119,200)', 'rgb(203,122,119)'],
          data: <int>[_getValue(current.genders, 'm'), _getValue(current.genders, 'x'), _getValue(current.genders, 'f')])
    ]);

    _createDoughnutChart(data, 'Kön', selector);
  }

  void _createPaymentsChart(String selector) {
    if (current.bookingsByPayment.isEmpty) return;

    final data = LinearChartData(labels: <String>[
      'Ej betalade',
      'Betalade'
    ], datasets: <ChartDataSets>[
      ChartDataSets(
          backgroundColor: <String>['rgb(201,136,98)', 'rgb(117,209,132)'],
          data: <int>[_getValue(current.bookingsByPayment, 'unpaid'), _getValue(current.bookingsByPayment, 'paid')])
    ]);

    _createDoughnutChart(data, 'Betalning', selector);
  }

  void _createLineChart(LinearChartData data, String label, String selector) {
    final config = ChartConfiguration(
        data: data, type: 'line', options: ChartOptions(legend: ChartLegendOptions(display: false), responsive: true, title: _createTitle(label)));

    Chart(querySelector(selector), config);
  }

  void _createPaxAndCapacityChart(String selector) {
    final data = LinearChartData(labels: summary.labels, datasets: <ChartDataSets>[
      ChartDataSets(label: 'Totalt antal deltagare', backgroundColor: 'rgba(58,199,151,0.6)', data: summary.paxTotal),
      ChartDataSets(label: 'Total bokad kapacitet', backgroundColor: 'rgba(21,112,98,0.2)', data: summary.capacityTotal)
    ]);

    _createLineChart(data, 'Totalt antal deltagare/kapacitet', selector);
  }

  void _createSimpleLineChart(List<int> values, String label, String backgroundColor, String selector) {
    final data =
        LinearChartData(labels: summary.labels, datasets: <ChartDataSets>[ChartDataSets(backgroundColor: backgroundColor, data: values, label: label)]);

    _createLineChart(data, label, selector);
  }

  ChartTitleOptions _createTitle(String label) => ChartTitleOptions(
      display: true, fontColor: 'black', fontFamily: 'Raleway, Helvetica, Arial, sans-serif', fontSize: 20, padding: 15, fontStyle: 'normal', text: label);

  int _getValue(List<KeyValuePair> source, String key) {
    final pair = source.firstWhere((KeyValuePair pair) => pair.key == key, orElse: () => null);
    return null != pair ? pair.value : 0;
  }
}
