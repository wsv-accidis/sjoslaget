import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:quiver/strings.dart' show isNotEmpty;
import 'package:frontend_shared/widget/modal_dialog.dart';

import '../booking/booking_validator.dart';
import '../client/client_factory.dart';
import '../client/day_booking_repository.dart';
import '../model/day_booking_type.dart';
import '../model/day_booking_view.dart';
import '../util/food.dart';
import '../util/gender.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(selector: 'admin-day-booking-page', templateUrl: 'admin_day_booking_page.html', styleUrls: [
  '../content/content_styles.css',
  'admin_styles.css',
  'admin_day_booking_page.css'
], directives: <dynamic>[
  coreDirectives,
  routerDirectives,
  formDirectives,
  gotlandMaterialDirectives,
  ModalDialog,
  SpinnerWidget
], providers: <dynamic>[
  materialProviders
], exports: <dynamic>[
  AdminRoutes
])
class AdminDayBookingPage implements OnActivate {
  final BookingValidator _bookingValidator;
  final DayBookingRepository _dayBookingRepository;
  final ClientFactory _clientFactory;
  final Router _router;

  @ViewChild('deleteBookingDialog')
  ModalDialog deleteBookingDialog;

  DayBookingView booking;
  String bookingError;
  List<DayBookingType> types;
  bool isSaving = false;
  String loadingError;
  SelectionOptions<DayBookingType> typeOptions;

  bool get canSubmit => booking.isValid && !isSaving;

  SelectionOptions<String> get foodOptions => Food.getOptions();

  SelectionOptions<String> get genderOptions => Gender.getOptions();

  bool get hasBookingError => isNotEmpty(bookingError);

  bool get hasLoadingError => isNotEmpty(loadingError);

  bool get isLoading => null == booking || null == types;

  AdminDayBookingPage(this._bookingValidator, this._dayBookingRepository, this._clientFactory, this._router);

  Future<void> deleteBooking() async {
    if (isSaving) return;
    if (!await deleteBookingDialog.openAsync()) return;

    isSaving = true;

    try {
      final client = _clientFactory.getClient();
      await _dayBookingRepository.deleteBooking(client, booking.reference);
    } catch (e) {
      print('Failed to delete day booking: ${e.toString()}');
    } finally {
      isSaving = false;
    }

    await _router.navigateByUrl(AdminRoutes.dayBookingList.toUrl());
  }

  String foodToString(dynamic f) => Food.asString(f);

  String genderToString(dynamic g) => Gender.asString(g);

  String typeToString(dynamic t) => (null == t) ? '' : '${t.title} (${t.price} kr)';

  @override
  Future<void> onActivate(_, RouterState routerState) async {
    final String reference = routerState.parameters['ref'];

    try {
      final client = _clientFactory.getClient();
      types = await _dayBookingRepository.getTypes(client);
      typeOptions = SelectionOptions.fromList(types);
      final bookingSource = await _dayBookingRepository.getBooking(client, reference);
      booking = DayBookingView.fromDayBookingSource(bookingSource, types);
    } catch (e) {
      print('Failed to load day booking: ${e.toString()}');
      loadingError = 'Någonting gick fel och dagbiljetten kunde inte hämtas. Ladda om sidan och försök igen.';
    }
  }

  Future<void> saveBooking() async {
    if (isSaving) return;

    isSaving = true;
    bookingError = null;
    try {
      final client = _clientFactory.getClient();
      await _dayBookingRepository.saveBooking(client, booking.toDayBookingSource());
    } catch (e) {
      bookingError =
          'Någonting gick fel när dagbiljetten skulle sparas. Kontrollera att alla uppgifter är riktigt angivna och försök igen.';
    } finally {
      isSaving = false;
    }
  }

  void validate(Event event) {
    _bookingValidator.validateDay(booking);
  }
}
