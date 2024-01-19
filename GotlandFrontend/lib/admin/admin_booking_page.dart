import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/admin/payment_history_component.dart';
import 'package:frontend_shared/model/booking_result.dart';
import 'package:frontend_shared/util.dart';
import 'package:frontend_shared/widget/modal_dialog.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../client/user_repository.dart';
import '../model/booking_pax_view.dart';
import '../model/booking_source.dart';
import '../model/cabin_class.dart';
import '../util/temp_credentials_store.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';
import 'allocation_component.dart';
import 'pax_component.dart';
import 'payment_component.dart';

@Component(selector: 'admin-booking-page', templateUrl: 'admin_booking_page.html', styleUrls: [
  '../content/content_styles.css',
  'admin_styles.css',
  'admin_booking_page.css'
], directives: <dynamic>[
  coreDirectives,
  routerDirectives,
  formDirectives,
  gotlandMaterialDirectives,
  AllocationComponent,
  PaymentComponent,
  PaymentHistoryComponent,
  PaxComponent,
  ModalDialog,
  SpinnerWidget
], providers: <dynamic>[
  materialProviders
], exports: <dynamic>[
  AdminRoutes
])
class AdminBookingPage implements OnActivate {
  final BookingRepository _bookingRepository;
  final ClientFactory _clientFactory;
  final EventRepository _eventRepository;
  final Router _router;
  final TempCredentialsStore _tempCredentialsStore;
  final UserRepository _userRepository;

  @ViewChild('allocation')
  AllocationComponent allocation;

  @ViewChild('deleteBookingDialog')
  ModalDialog deleteBookingDialog;

  @ViewChild('payment')
  PaymentComponent payment;

  @ViewChild('pax')
  PaxComponent pax;

  BookingSource booking;
  BookingResult bookingResult;
  String bookingError;
  List<CabinClass> cabinClasses;
  bool isSaving = false;
  String loadingError;
  String newPinCode;
  int noOfPax = 0;
  String resetPinCodeError;

  bool get canSave => !pax.isEmpty && pax.isValid && !isSaving;

  String get confirmationSentMessage => hasSentConfirmation
      ? 'Bekräftelse skickad ${DateTimeFormatter.format(booking.confirmationSent)}'
      : 'Bekräftelse inte skickad';

  bool get hasBookingResult => null != bookingResult;

  bool get hasSentConfirmation => null != booking.confirmationSent;

  bool get hasBookingError => isNotEmpty(bookingError);

  bool get hasLoadingError => isNotEmpty(loadingError);

  bool get hasPax => numberOfPax > 0;

  bool get hasResetPinCode => isNotEmpty(newPinCode);

  bool get hasResetPinCodeError => isNotEmpty(resetPinCodeError);

  bool get isLoading => null == booking;

  bool get isLocked => null != booking && booking.isLocked;

  int get numberOfPax => null != booking ? booking.pax.length : 0;

  AdminBookingPage(this._bookingRepository, this._clientFactory, this._eventRepository, this._router,
      this._tempCredentialsStore, this._userRepository);

  void addEmptyPax() {
    pax.addEmptyPax();
  }

  Future<void> confirmBooking() async {
    if (isSaving) return;

    isSaving = true;

    try {
      final client = _clientFactory.getClient();
      await _bookingRepository.confirmBooking(client, booking.reference);
      booking.confirmationSent = DateTime.now();
      booking.isLocked = true;
    } catch (e) {
      print('Failed to confirm booking: ${e.toString()}');
    } finally {
      isSaving = false;
    }
  }

  Future<void> deleteBooking() async {
    if (isSaving) return;
    if (!await deleteBookingDialog.openAsync()) return;

    isSaving = true;

    try {
      final client = _clientFactory.getClient();
      await _bookingRepository.deleteBooking(client, booking.reference);
    } catch (e) {
      print('Failed to delete booking: ${e.toString()}');
    } finally {
      isSaving = false;
    }

    await _router.navigateByUrl(AdminRoutes.dashboard.toUrl());
  }

  Future<void> lockUnlockBooking() async {
    if (isSaving) return;

    isSaving = true;

    try {
      final client = _clientFactory.getClient();
      final bool isLocked = await _bookingRepository.lockUnlockBooking(client, booking.reference);
      booking.isLocked = isLocked;
    } catch (e) {
      print('Failed to lock/unlock booking: ${e.toString()}');
    } finally {
      isSaving = false;
    }
  }

  @override
  Future<void> onActivate(_, RouterState routerState) async {
    final String reference = routerState.parameters['ref'];

    try {
      final client = _clientFactory.getClient();
      booking = await _bookingRepository.getBooking(client, reference);
      cabinClasses = await _eventRepository.getActiveCabinClasses(client);
      pax.pax = BookingPaxView.listOfBookingPaxToList(booking.pax, cabinClasses);

      await allocation.load();
    } catch (e) {
      print('Failed to load booking: ${e.toString()}');
      loadingError = 'Någonting gick fel och bokningen kunde inte hämtas. Ladda om sidan och försök igen.';
      return;
    }

    bookingResult = _tempCredentialsStore.load();
    if (null != bookingResult && bookingResult.reference != reference) {
      bookingResult = null;
      _tempCredentialsStore.clear();
    }
  }

  Future<void> resetPinCode() async {
    if (isSaving) return;

    isSaving = true;
    resetPinCodeError = null;

    try {
      final client = _clientFactory.getClient();
      final String pinCode = await _userRepository.resetPinCode(client, booking.reference);

      if (isNotEmpty(pinCode)) newPinCode = pinCode;
    } catch (e) {
      print('Failed to reset PIN code: ${e.toString()}');
      resetPinCodeError = 'Någonting gick fel när PIN-koden skulle återställas. Försök igen.';
    } finally {
      isSaving = false;
    }
  }

  Future<void> saveBooking() async {
    if (isSaving) return;

    isSaving = true;
	bookingError = null;

    try {
      booking.pax = BookingPaxView.listToListOfBookingPax(pax.paxViews);
      try {
        final client = _clientFactory.getClient();
        await _bookingRepository.saveBooking(client, booking);
      } catch (e) {
        bookingError =
            'Någonting gick fel när bokningen skulle sparas. Kontrollera att alla uppgifter är riktigt angivna och försök igen.';
      }
    } finally {
      isSaving = false;
    }
  }
}
