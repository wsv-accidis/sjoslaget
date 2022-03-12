import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' as str show isNotBlank;

import '../admin/solo_component.dart';
import '../client/client_factory.dart';
import '../client/day_booking_repository.dart';
import '../model/day_booking_source.dart';
import '../model/day_booking_type.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'content_routes.dart';

@Component(
    selector: 'day-booking-page',
    templateUrl: 'day_booking_page.html',
    styleUrls: ['../content/content_styles.css', 'day_booking_page.css'],
    directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives, routerDirectives, SoloComponent, SpinnerWidget],
    exports: [ContentRoutes])
class DayBookingPage implements OnInit {
  final ClientFactory _clientFactory;
  final DayBookingRepository _dayBookingRepository;

  bool _memberOfRindi;
  List<DayBookingType> _types;
  bool hasError = false;
  bool isSaving = false;
  String lastSavedName;

  @ViewChild('booking')
  SoloComponent booking;

  DayBookingType type;

  bool get canSubmit => !isSaving && !isLoading && !booking.isEmpty && booking.isValid;

  bool get hasSaved => str.isNotBlank(lastSavedName);

  bool get isLoading => null == booking || null == type;

  bool get memberOfRindi => _memberOfRindi;

  set memberOfRindi(bool value) {
    _memberOfRindi = value;
    type = value ? _types[0] : _types[1];
  }

  String get priceFormatted => CurrencyFormatter.formatDecimalAsSEK(type.price);

  DayBookingPage(this._clientFactory, this._dayBookingRepository);

  @override
  Future<void> ngOnInit() async {
    _clientFactory.clear();
    try {
      final client = _clientFactory.getClient();
      _types = await _dayBookingRepository.getTypes(client);

      if (2 != _types.length) {
        print('Invalid data from server, expected two types of day bookings.');
        return;
      }

      // Initalize to non-member first
      memberOfRindi = false;
    } catch (e) {
      // Ignore this here - we will be stuck in the loading state until the user refreshes
      print('Failed to get data due to an exception: ${e.toString()}');
      return;
    }
  }

  Future<void> submit() async {
    hasError = false;
    isSaving = true;

    try {
      final client = _clientFactory.getClient();
      final source = DayBookingSource.fromSoloView(booking.view, type.id);
      await _dayBookingRepository.saveBooking(client, source);
    } catch (e) {
      print('Failed to save day booking: ${e.toString()}');
      hasError = true;
    } finally {
      if (!hasError) {
        lastSavedName = '${booking.view.firstName} ${booking.view.lastName}';
        booking.clear();
      }
      isSaving = false;
    }
  }
}
