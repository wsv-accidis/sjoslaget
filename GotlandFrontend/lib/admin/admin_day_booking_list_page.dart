import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:frontend_shared/widget/paging_support.dart';
import 'package:frontend_shared/widget/sortable_columns.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/client_factory.dart';
import '../client/day_booking_repository.dart';
import '../model/day_booking_list_item.dart';
import '../model/day_booking_type.dart';
import '../util/food.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(selector: 'admin-day-booking-list-page', templateUrl: 'admin_day_booking_list_page.html', styleUrls: [
  '../content/content_styles.css',
  'admin_styles.css',
  'admin_day_booking_list_page.css'
], directives: <dynamic>[
  coreDirectives,
  formDirectives,
  routerDirectives,
  gotlandMaterialDirectives,
  SortableColumnHeader,
  SortableColumns,
  SpinnerWidget
], providers: <dynamic>[
  materialProviders
], exports: <dynamic>[
  AdminRoutes
])
class AdminDayBookingListPage implements OnInit {
  static const int PAGE_LIMIT = 40;
  static const String STATUS_NONE = 'none';
  static const String STATUS_CONFIRMED = 'confirmed';
  static const String STATUS_NOT_CONFIRMED = 'not-confirmed';

  final DayBookingRepository _bookingRepository;
  final ClientFactory _clientFactory;

  List<DayBookingListItem> _bookings;
  String _filterPayment = STATUS_NONE;
  String _filterText = '';
  Map<String, DayBookingType> _types;

  List<DayBookingListItem> bookingsView;
  final PagingSupport paging = PagingSupport(PAGE_LIMIT);
  SortableState sort = SortableState('name', false);

  AdminDayBookingListPage(this._bookingRepository, this._clientFactory);

  bool get isLoading => null == bookingsView;

  String get filterPayment => _filterPayment;

  set filterPayment(String value) {
    _filterPayment = value;
    _refreshView();
  }

  String get filterText => _filterText;

  set filterText(String value) {
    _filterText = value;
    _refreshView();
  }

  String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

  String formatFood(String food) => Food.asString(food);

  String formatType(String typeId) =>
      _types.containsKey(typeId) ? '${_types[typeId].title} (${_types[typeId].price} kr)' : '-';

  String getStatus(DayBookingListItem booking) => booking.paymentConfirmed ? STATUS_CONFIRMED : STATUS_NOT_CONFIRMED;

  @override
  Future<void> ngOnInit() async {
    paging.refreshCallback = _refreshView;
    await refresh();
  }

  void onFilterChanged() {
    _refreshView();
  }

  void onSortChanged(SortableState state) {
    sort = state;
    _refreshView();
  }

  Future<void> refresh() async {
    try {
      final client = _clientFactory.getClient();
      final types = await _bookingRepository.getTypes(client);
      _types = Map.fromIterable(types, key: (dynamic e) => e.id);
      _bookings = await _bookingRepository.getList(client);
      _refreshView();
    } catch (e) {
      print('Failed to load list of day bookings: ${e.toString()}');
      // Just ignore this here, we will be stuck in the loading state until the user refreshes
    }
  }

  int _comparator(DayBookingListItem one, DayBookingListItem two) {
    if (sort.desc) {
      final DayBookingListItem temp = two;
      two = one;
      one = temp;
    }

    switch (sort.column) {
      case 'paymentStatus':
        return _statusAsInt(getStatus(one)) - _statusAsInt(getStatus(two));
      case 'reference':
        return one.reference.compareTo(two.reference);
      case 'name':
        return ValueComparer.compareStringPairIgnoreCase(one.firstName, one.lastName, two.firstName, two.lastName);
      case 'phone':
        return one.phoneNo.compareTo(two.phoneNo);
      case 'dob':
        return one.dob.compareTo(two.dob);
      case 'food':
        return one.food.compareTo(two.food);
      case 'type':
        return _typeAsTitle(one.typeId).compareTo(_typeAsTitle(two.typeId));
      case 'updated':
        return two.updated.compareTo(one.updated);
      default:
        print('Unrecognized column \"${sort.column}\", no sort applied.');
        return 0;
    }
  }

  void _refreshView() {
    Iterable<DayBookingListItem> filtered = _bookings;

    if (isNotEmpty(_filterText)) {
      final filterText = _filterText.toLowerCase().trim();
      filtered = filtered
          .where((b) => '${b.reference} ${b.firstName} ${b.lastName} ${b.phoneNo}'.toLowerCase().contains(filterText));
    }
    if (STATUS_CONFIRMED == _filterPayment) {
      filtered = filtered.where((b) => b.paymentConfirmed);
    } else if (STATUS_NOT_CONFIRMED == _filterPayment) {
      filtered = filtered.where((b) => !b.paymentConfirmed);
    }

    final List<DayBookingListItem> sorted = filtered.toList(growable: false);
    sorted.sort(_comparator);

    bookingsView = paging.apply(sorted);
  }

  int _statusAsInt(String status) {
    switch (status) {
      case STATUS_NOT_CONFIRMED:
        return 0;
      case STATUS_CONFIRMED:
        return 1;
      default:
        return 2;
    }
  }

  String _typeAsTitle(String typeId) => _types.containsKey(typeId) ? _types[typeId].title : '';
}
