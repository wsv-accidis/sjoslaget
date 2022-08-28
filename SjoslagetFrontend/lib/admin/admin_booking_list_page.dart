import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/model/booking_payment_model.dart';
import 'package:frontend_shared/util.dart';
import 'package:frontend_shared/widget/paging_support.dart';
import 'package:frontend_shared/widget/sortable_columns.dart';
import 'package:quiver/strings.dart' show isEmpty, isNotEmpty;

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/printer_repository.dart';
import '../model/booking_overview_item.dart';
import '../model/sub_cruise.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';
import 'booking_preview_component.dart';

@Component(selector: 'admin-booking-list-page', templateUrl: 'admin_booking_list_page.html', styleUrls: [
  '../content/content_styles.css',
  'admin_styles.css',
  'admin_booking_list_page.css'
], directives: <dynamic>[
  coreDirectives,
  routerDirectives,
  sjoslagetMaterialDirectives,
  BookingPreviewComponent,
  SortableColumnHeader,
  SortableColumns,
  SpinnerWidget
], providers: <dynamic>[
  materialProviders
], exports: <dynamic>[
  AdminRoutes
])
class AdminBookingListPage implements OnInit, OnDestroy {
  static const String LOCKED = 'locked';
  static const int PAGE_LIMIT = 20;

  final BookingRepository _bookingRepository;
  final ClientFactory _clientFactory;
  final PrinterRepository _printerRepository;

  List<BookingOverviewItem> _bookings;
  String _filterLunch = '';
  String _filterStatus = BookingPaymentModel.STATUS_NONE;
  String _filterText = '';
  Timer _timer;

  @ViewChild('bookingPreview')
  BookingPreviewComponent bookingPreview;

  List<BookingOverviewItem> bookingsView;
  final PagingSupport paging = PagingSupport(PAGE_LIMIT);
  bool printerIsAvailable = false;
  SortableState sort = SortableState('reference', false);

  AdminBookingListPage(this._bookingRepository, this._clientFactory, this._printerRepository);

  String get filterLunch => _filterLunch;

  set filterLunch(String value) {
    _filterLunch = value;
    _refreshView();
  }

  String get filterStatus => _filterStatus;

  set filterStatus(String value) {
    _filterStatus = value;
    _refreshView();
  }

  String get filterText => _filterText;

  set filterText(String value) {
    _filterText = value;
    _refreshView();
  }

  bool get isLoading => null == bookingsView;

  String formatCurrency(Decimal amount) => CurrencyFormatter.formatDecimalAsSEK(amount);

  String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

  String formatLunch(String lunch) => (isEmpty(lunch) || lunch == '-') ? '-' : '$lunch:00';

  String formatSubCruise(String code) => SubCruise.codeToLabel(code);

  String getStatus(BookingOverviewItem item) {
    if (item.isLocked) return LOCKED;
    return item.status;
  }

  @override
  Future<void> ngOnInit() async {
    paging.refreshCallback = _refreshView;

    await refresh();
    await _refreshPrinterState();

    _timer = Timer.periodic(Duration(seconds: 30), _tick);
  }

  @override
  void ngOnDestroy() {
    if (null != _timer) _timer.cancel();
  }

  void onFilterChanged() {
    _refreshView();
  }

  void onSortChanged(SortableState state) {
    sort = state;
    _refreshView();
  }

  void openPreviewPopup(BookingOverviewItem booking) {
    bookingPreview.open(booking);
  }

  Future<void> printBooking(BookingOverviewItem booking) async {
    final client = _clientFactory.getClient();
    await _printerRepository.enqueue(client, booking.reference);
  }

  Future<void> refresh() async {
    try {
      final client = _clientFactory.getClient();
      _bookings = await _bookingRepository.getOverview(client);
      _refreshView();
    } catch (e) {
      print('Failed to load list of bookings: ${e.toString()}');
      // Just ignore this here, we will be stuck in the loading state until the user refreshes
    }
  }

  int _bookingComparator(BookingOverviewItem one, BookingOverviewItem two) {
    if (sort.desc) {
      // Swap the items when using descending sort, so we can keep the rest identical
      final BookingOverviewItem temp = two;
      two = one;
      one = temp;
    }

    switch (sort.column) {
      case 'status':
        return _statusToInt(one) - _statusToInt(two);
      case 'reference':
        return one.reference.compareTo(two.reference);
      case 'subCruise':
        return SubCruise.codeToOrdinal(one.subCruise) - SubCruise.codeToOrdinal(two.subCruise);
      case 'contact':
        return ValueComparer.compareStringPair(one.firstName, one.lastName, two.firstName, two.lastName);
      case 'lunch':
        return one.lunch.compareTo(two.lunch);
      case 'noOfCabins':
        return one.numberOfCabins - two.numberOfCabins;
      case 'amountPaid':
        return one.amountPaid.compareTo(two.amountPaid);
      case 'amountRemaining':
        return one.amountRemaining.compareTo(two.amountRemaining);
      case 'updated':
        return two.updated.compareTo(one.updated);
      default:
        print('Unrecognized column \"${sort.column}\", no sort applied.');
        return 0;
    }
  }

  Future<void> _refreshPrinterState() async {
    final client = _clientFactory.getClient();
    printerIsAvailable = await _printerRepository.isAvailable(client);
  }

  void _refreshView() {
    Iterable<BookingOverviewItem> filtered = _bookings;

    if (isNotEmpty(_filterText)) {
      final filterText = _filterText.toLowerCase().trim();
      filtered = filtered.where((b) => '${b.reference} ${b.firstName} ${b.lastName}'.toLowerCase().contains(filterText));
    }
    if (BookingPaymentModel.STATUS_NONE != _filterStatus) {
      filtered = filtered.where((b) => getStatus(b) == _filterStatus);
    }
    if (isNotEmpty(_filterLunch)) {
      filtered = filtered.where((b) => b.lunch == _filterLunch);
    }

    // Can't sort an iterable in Dart without turning it to a list first
    final List<BookingOverviewItem> sorted = filtered.toList(growable: false);
    sorted.sort(_bookingComparator);

    bookingsView = paging.apply(sorted);
  }

  static int _statusToInt(BookingOverviewItem item) {
    if (item.isLocked) return 4;

    return item.statusAsInt;
  }

  Future<void> _tick(Timer ignored) async {
    await _refreshPrinterState();
  }
}
