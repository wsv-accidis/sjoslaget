import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/model/booking_result.dart';
import 'package:http/http.dart' show Client;
import 'package:quiver/strings.dart' show isNotEmpty;

import '../admin/pax_component.dart';
import '../admin/payment_component.dart';
import '../client/allocation_repository.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../content/about_routes.dart';
import '../content/content_routes.dart';
import '../model/booking_allocation_view.dart';
import '../model/booking_pax_view.dart';
import '../model/booking_queue_stats.dart';
import '../model/booking_source.dart';
import '../model/cabin_class.dart';
import '../model/team_size.dart';
import '../util/temp_credentials_store.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';

@Component(
    selector: 'booking-page',
    styleUrls: ['../content/content_styles.css', 'booking_edit_page.css'],
    templateUrl: 'booking_edit_page.html',
    directives: <dynamic>[
      coreDirectives,
      routerDirectives,
      formDirectives,
      gotlandMaterialDirectives,
      PaxComponent,
      PaymentComponent,
      SpinnerWidget
    ],
    providers: <dynamic>[materialProviders],
    exports: [AboutRoutes, ContentRoutes])
class BookingEditPage implements OnInit {
  final AllocationRepository _allocationRepository;
  final BookingRepository _bookingRepository;
  final ClientFactory _clientFactory;
  final EventRepository _eventRepository;
  final Router _router;
  final TempCredentialsStore _tempCredentialsStore;

  @ViewChild('pax')
  PaxComponent pax;

  List<BookingAllocationView> allocation;
  BookingSource booking;
  String bookingError;
  List<CabinClass> cabinClasses;
  BookingResult credentials;
  bool isReadOnly = false;
  bool isSaving = false;
  String loadingError;
  BookingQueueStats queueStats;

  bool get canAddPax => pax.count < TEAM_SIZE_MAX;

  bool get canSave => !pax.isEmpty && pax.isValid && !isSaving;

  bool get hasAllocation => null != allocation && allocation.isNotEmpty && isReadOnly;

  bool get hasCredentials => null != credentials;

  bool get hasBookingError => isNotEmpty(bookingError);

  bool get hasLoadingError => isNotEmpty(loadingError);

  bool get hasQueueStats => null != queueStats && !queueStats.isEmpty;

  bool get isLoaded => null != booking;

  bool get isNewBooking => isLoaded && pax.isEmpty && !isReadOnly;

  int get price => hasAllocation ? allocation.fold(0, (sum, a) => sum + a.price) : 200;

  BookingEditPage(this._allocationRepository, this._bookingRepository, this._clientFactory, this._eventRepository,
      this._router, this._tempCredentialsStore);

  @override
  Future<void> ngOnInit() async {
    if (!_clientFactory.hasCredentials || _clientFactory.isAdmin) {
      print('Booking page opened without credentials or while logged in as admin.');
      await _router.navigateByUrl(ContentRoutes.booking.toUrl());
      return;
    }

    final String reference = _clientFactory.authenticatedUser;
    try {
      final client = _clientFactory.getClient();
      final event = await _eventRepository.getActiveEvent(client);
      cabinClasses = await _eventRepository.getActiveCabinClasses(client);
      booking = await _bookingRepository.getBooking(client, reference);
      isReadOnly = event.isLocked || booking.isLocked;
      queueStats = await _bookingRepository.getQueueStats(client, reference);
      allocation = await _loadAllocation(client, reference);
    } catch (e) {
      print('Failed to get booking due to an exception: ${e.toString()}');
      loadingError =
          'Någonting gick fel och bokningen kunde inte hämtas. Ladda om sidan och försök igen. Om felet kvarstår, kontakta oss.';
      return;
    }

    credentials = _tempCredentialsStore.load();
    pax.isReadOnly = isReadOnly;

    if (!isReadOnly && booking.pax.isEmpty) {
      // For new bookings, helpfully create a bunch of empty rows
      final int teamSize =
          queueStats.teamSize <= 0 || queueStats.teamSize > TEAM_SIZE_MAX ? TEAM_SIZE_DEFAULT : queueStats.teamSize;
      pax.emptyPax = teamSize;
    } else {
      pax.pax = BookingPaxView.listOfBookingPaxToList(booking.pax, cabinClasses);
    }
  }

  void addEmptyPax() {
    if (canAddPax) {
      pax.addEmptyPax();
    }
  }

  Future<void> saveAndExit() async {
    if (!isReadOnly) {
      await saveBooking();
    }
    if (null == bookingError) {
      _clientFactory.clear();
      await _router.navigateByUrl(ContentRoutes.booking.toUrl());
    }
  }

  Future<void> saveBooking() async {
    _tempCredentialsStore.clear();

    if (isSaving) return;

    isSaving = true;
    try {
      bookingError = null;

      booking.pax = BookingPaxView.listToListOfBookingPax(pax.paxViews);
      try {
        final client = _clientFactory.getClient();
        await _bookingRepository.saveBooking(client, booking);
      } catch (e) {
        bookingError =
            'Någonting gick fel när din bokning skulle sparas. Kontrollera att alla uppgifter är riktigt angivna och försök igen. Om problemet kvarstår, kontakta oss.';
      }
    } finally {
      isSaving = false;
    }
  }

  Future<List<BookingAllocationView>> _loadAllocation(Client client, String reference) async {
    final alloc = await _allocationRepository.getAllocation(client, reference);

    if (alloc.isNotEmpty) {
      final details = await _eventRepository.getCabinClassDetails(client);
      return BookingAllocationView.fromListOfBookingAllocation(alloc, cabinClasses, details);
    } else {
      return <BookingAllocationView>[];
    }
  }
}
