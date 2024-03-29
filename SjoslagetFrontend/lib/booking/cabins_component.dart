import 'dart:async';
import 'dart:html' show Event, HtmlElement;

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart';

import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin_view.dart';
import '../model/cruise_cabin.dart';
import '../model/sub_cruise.dart';
import '../widgets/components.dart';
import 'booking_addon_provider.dart';
import 'booking_validator.dart';

@Component(
    selector: 'cabins-component',
    templateUrl: 'cabins_component.html',
    styleUrls: ['../content/content_styles.css', 'cabins_component.css', 'cabins_gender_field.css'],
    directives: <dynamic>[coreDirectives, formDirectives, sjoslagetMaterialDirectives])
class CabinsComponent implements OnInit {
  final BookingValidator _bookingValidator;
  final ClientFactory _clientFactory;
  final CruiseRepository _cruiseRepository;

  Map<String, int> _availability;
  final List<BookingCabinView> _pendingDeleteCabins = <BookingCabinView>[];
  Decimal amountPaid;
  List<BookingAddonProvider> bookingAddons = <BookingAddonProvider>[];
  List<BookingCabinView> bookingCabins = <BookingCabinView>[];
  List<CruiseCabin> cruiseCabins;
  bool disableAddCabins = false;
  int discountPercent = 0;
  bool hasSwitchedSubCruise = false;
  bool readOnly = false;
  String subCruise = 'A';
  String subCruiseError;
  List<SubCruise> subCruises;

  CabinsComponent(this._bookingValidator, this._clientFactory, this._cruiseRepository);

  String get amountPaidFormatted => CurrencyFormatter.formatDecimalAsSEK(hasPayment ? amountPaid : 0);

  Decimal get discount {
    final priceAsDec = Decimal.fromInt(priceOfCabins);
    final discountAsDec = Decimal.fromInt(discountPercent) / Decimal.fromInt(100);
    return priceAsDec * discountAsDec;
  }

  String get discountFormatted => CurrencyFormatter.formatDecimalAsSEK(discount);

  bool get hasAddons => priceOfAddons > 0;

  bool get hasDiscount => discountPercent > 0;

  bool get hasPayment => null != amountPaid && amountPaid.ceilToDouble() > 0.0;

  bool get hasPrice => price > 0;

  bool get hasSubCruiseError => isNotEmpty(subCruiseError);

  bool get isEmpty => bookingCabins.isEmpty;

  bool get isLoaded => null != _availability && null != cruiseCabins && null != subCruises;

  bool get isValid => bookingCabins.every((b) => b.isValid);

  int get price => priceOfCabins + priceOfAddons;

  int get priceOfAddons => bookingAddons.fold(0, (sum, a) => sum + a.price);

  int get priceOfCabins => bookingCabins.fold(0, (sum, b) => sum + b.price);

  String get priceFormatted => CurrencyFormatter.formatIntAsSEK(price);

  String get priceOfAddonsFormatted => CurrencyFormatter.formatIntAsSEK(priceOfAddons);

  String get priceOfCabinsFormatted => CurrencyFormatter.formatIntAsSEK(priceOfCabins);

  Decimal get priceRemaining => hasPayment ? priceWithDiscount - amountPaid : priceWithDiscount;

  String get priceRemainingFormatted => CurrencyFormatter.formatDecimalAsSEK(priceRemaining);

  Decimal get priceWithDiscount => Decimal.fromInt(price) - discount;

  String get priceWithDiscountFormatted => CurrencyFormatter.formatDecimalAsSEK(priceWithDiscount);

  String get nameOfSubCruise => subCruises.firstWhere((c) => c.code == subCruise).name;

  void addCabin(String id) {
    final cabin = _getCruiseCabin(id);
    final bookingCabin = BookingCabinView.fromCruiseCabin(cabin);
    if (bookingCabins.isEmpty) {
      // First pax of the booking must have group set so it can be used as the default for everyone else
      bookingCabin.pax[0].firstRow = true;
    }

    bookingCabins.add(bookingCabin);
    _bookingValidator.validateCabin(bookingCabin);
  }

  void deleteCabin(int idx) {
    final cabin = bookingCabins[idx];
    if (cabin.isSaved) _pendingDeleteCabins.add(cabin);

    bookingCabins.removeAt(idx);

    if (0 == idx && bookingCabins.isNotEmpty) {
      // Reapply the firstRow flag to the new first row if the old one was removed
      final firstCabin = bookingCabins[0];
      firstCabin.pax[0].firstRow = true;
      _bookingValidator.validateCabin(firstCabin);
    }
  }

  int getAvailability(String id) {
    final int available = getTotalAvailability(id);
    final int inBooking = getNumberOfCabinsInBooking(id);
    final int savedInBooking = _getNumberOfSavedCabinsInBooking(id);
    final int pendingDeletion = _getNumberOfCabinsPendingDeletion(id);
    return available - inBooking + savedInBooking + pendingDeletion;
  }

  List<CruiseCabin> getCruiseCabins() => cruiseCabins.where((c) => c.subCruise == subCruise).toList(growable: false);

  int getNumberOfCabinsInBooking(String id) => _getCabinsInBooking(id).length;

  int getTotalAvailability(String id) {
    if (null == _availability || !_availability.containsKey(id)) return 0;
    return _availability[id];
  }

  bool hasAvailability(String id) => getAvailability(id) > 0;

  @override
  Future<void> ngOnInit() async {
    try {
      final client = _clientFactory.getClient();
      cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
      subCruises = await _cruiseRepository.getActiveSubCruises(client);
      _availability = await _cruiseRepository.getCabinsAvailability(client);
    } catch (e) {
      print('Failed to get cabins or availability due to an exception: ${e.toString()}');
      // Ignore this here - we will be stuck in the loading state until the user refreshes
    }
  }

  void onSaved() {
    subCruiseError = null;
    hasSwitchedSubCruise = false;
    _pendingDeleteCabins.clear();
    for (BookingCabinView b in bookingCabins) b.isSaved = true;
  }

  Future<void> refreshAvailability() async {
    try {
      final client = _clientFactory.getClient();
      _availability = await _cruiseRepository.getCabinsAvailability(client);
    } catch (e) {
      print('Failed to refresh availability due to an exception: ${e.toString()}');
      // Ignore this here, keep using old availability
    }
  }

  void registerAddonProvider(BookingAddonProvider provider) {
    bookingAddons.add(provider);
  }

  void switchSubCruise(String newSubCruise) {
    if (subCruise == newSubCruise) {
      return;
    }
    if (bookingCabins.isEmpty) {
      subCruise = newSubCruise; // shortcut
      subCruiseError = null;
      return;
    }

    bool couldNotTransform = false;
    final cabins = bookingCabins.map((c) => BookingCabinView.copy(c)).toList();
    for (BookingCabinView cabin in cabins) {
      final newCabin = _tryTransformCruiseCabin(cabin.id, newSubCruise);
      if (null == newCabin) {
        couldNotTransform = true;
        break;
      }
      cabin.id = newCabin.id;
    }

    if (couldNotTransform) {
      subCruiseError = 'Det gick inte att byta kryssning. Förmodligen beror det på att hytterna inte finns tillgängliga. Kontakta oss om du behöver hjälp.';
      return;
    }

    _pendingDeleteCabins.addAll(bookingCabins.where((c) => c.isSaved));
    bookingCabins = cabins;
    validateAll();

    subCruise = newSubCruise;
    hasSwitchedSubCruise = true;
    subCruiseError = null;
  }

  String uniqueId(String prefix, int cabin, int pax) {
    final idx = (100 * cabin) + pax;
    // We must include the subCruise in the ID, otherwise change tracking bugs out completely when switching
    return '${prefix}_${subCruise}_${idx.toString()}';
  }

  void validate(Event event) {
    final bookingIdx = _findBookingIndex(event.target);
    if (bookingIdx >= 0 && bookingIdx < bookingCabins.length) {
      _bookingValidator.validateCabin(bookingCabins[bookingIdx]);
    }
  }

  void validateAll() => bookingCabins.forEach(_bookingValidator.validateCabin);

  int _findBookingIndex(HtmlElement target) {
    if (!target.dataset.containsKey('idx')) {
      return null == target.parent ? -1 : _findBookingIndex(target.parent);
    }
    return int.parse(target.dataset['idx']);
  }

  Iterable<BookingCabinView> _getCabinsInBooking(String id) => bookingCabins.where((b) => b.id == id);

  CruiseCabin _getCruiseCabin(String id) => cruiseCabins.firstWhere((c) => c.id == id);

  int _getNumberOfSavedCabinsInBooking(String id) => _getCabinsInBooking(id).where((b) => b.isSaved).length;

  int _getNumberOfCabinsPendingDeletion(String id) => _pendingDeleteCabins.where((c) => c.id == id).length;

  CruiseCabin _tryTransformCruiseCabin(String sourceId, String targetSubCruise) {
    final sourceCabin = _getCruiseCabin(sourceId);
    return cruiseCabins.firstWhere((c) => c.name == sourceCabin.name && c.subCruise == targetSubCruise, orElse: () => null);
  }
}
