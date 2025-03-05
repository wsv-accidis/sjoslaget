import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' as str show isNotBlank;

import '../admin/solo_component.dart';
import '../client/client_factory.dart';
import '../client/day_booking_repository.dart';
import '../client/duplicate_booking_exception.dart';
import '../client/event_repository.dart';
import '../client/sold_out_exception.dart';
import '../model/day_booking_capacity.dart';
import '../model/day_booking_source.dart';
import '../model/day_booking_type.dart';
import '../model/event.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'content_routes.dart';

@Component(selector: 'day-booking-page', templateUrl: 'day_booking_page.html', styleUrls: [
  '../content/content_styles.css',
  'day_booking_page.css'
], directives: <dynamic>[
  coreDirectives,
  formDirectives,
  gotlandMaterialDirectives,
  routerDirectives,
  SoloComponent,
  SpinnerWidget
], exports: [
  ContentRoutes
])
class DayBookingPage implements OnInit {
  final ClientFactory _clientFactory;
  final DayBookingRepository _dayBookingRepository;
  final EventRepository _eventRepository;

  DayBookingCapacity _capacity;
  Event _evnt;
  DayBookingType _typeMember;
  DayBookingType _typeNonMember;

  bool hasDuplicateError = false;
  bool hasError = false;
  bool hasSoldOutError = false;
  bool isSaving = false;
  String lastSavedName;
  bool memberOfRindi;
  int remainingCapacity = 0;

  @ViewChild('booking')
  SoloComponent booking;

  bool get canSubmit => !isSaving && !isLoading && hasValidBooking;

  bool get hasSaved => str.isNotBlank(lastSavedName);

  bool get hasValidBooking => null != booking && !booking.isEmpty && booking.isValid;

  bool get isLoading => null == _evnt || null == _typeMember || null == _typeNonMember || null == _capacity;

  bool get isOpen => null != _evnt && _evnt.hasOpened;

  String get priceFormatted => CurrencyFormatter.formatDecimalAsSEK(type.price);

  DayBookingType get type => memberOfRindi ? _typeMember : _typeNonMember;

  DayBookingPage(this._clientFactory, this._dayBookingRepository, this._eventRepository);

  @override
  Future<void> ngOnInit() async {
    _clientFactory.clear();
    try {
      final client = _clientFactory.getClient();
      _evnt = await _eventRepository.getActiveEvent(client);

      final types = await _dayBookingRepository.getTypes(client);
      _typeMember = types.firstWhere((t) => t.isMember);
      _typeNonMember = types.firstWhere((t) => !t.isMember);

      await _refreshCapacity();

      // Initalize to non-member first
      memberOfRindi = false;
    } catch (e) {
      // Ignore this here - we will be stuck in the loading state until the user refreshes
      print('Failed to get data due to an exception: ${e.toString()}');
      return;
    }
  }

  void resetForm() {
    lastSavedName = '';
    _clearErrors();
  }

  Future<void> submit() async {
    _clearErrors();
    isSaving = true;

    try {
      final client = _clientFactory.getClient();
      final source = DayBookingSource.fromSoloView(booking.view, type.id);
      await _dayBookingRepository.createBooking(client, source);
    } on SoldOutException {
      hasSoldOutError = true;
    } on DuplicateBookingException {
      hasDuplicateError = true;
    } catch (e) {
      print('Failed to save day booking: ${e.toString()}');
      hasError = true;
    } finally {
      if (!hasError && !hasSoldOutError && !hasDuplicateError) {
        lastSavedName = '${booking.view.firstName} ${booking.view.lastName}';
        booking.clear();
      }
      isSaving = false;
    }

    await _refreshCapacity();
  }

  void _clearErrors() {
    hasDuplicateError = false;
    hasError = false;
    hasSoldOutError = false;
  }

  Future<void> _refreshCapacity() async {
    try {
      final client = _clientFactory.getClient();
      _capacity = await _dayBookingRepository.getCapacity(client);
      remainingCapacity = _capacity.capacity - _capacity.count;
    } catch (e) {
      print('Failed to refresh capacity: ${e.toString()}');
    }
  }
}
