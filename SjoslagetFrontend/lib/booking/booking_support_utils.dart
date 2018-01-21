import 'dart:async';

import 'package:frontend_shared/model.dart' show BookingResult;
import 'package:tuple/tuple.dart';

import 'cabins_component.dart';
import 'products_component.dart';
import '../client/availability_exception.dart';
import '../client/booking_exception.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../model/booking_cabin.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_details.dart';
import '../model/booking_product.dart';
import '../model/booking_product_view.dart';
import '../model/booking_source.dart';
import '../model/cruise_cabin.dart';
import '../model/cruise_product.dart';

class BookingSupportUtils {
	static Future<Tuple2<BookingResult, String>> saveBooking(ClientFactory clientFactory, BookingRepository bookingRepository,
		BookingDetails bookingDetails, CabinsComponent cabins, ProductsComponent products, BookingResult bookingResult) async {
		final List<BookingCabin> cabinsToSave = BookingCabinView.listToListOfBookingCabin(cabins.bookingCabins);
		final List<BookingProduct> productsToSave = BookingProductView.listToListOfBookingProduct(products.bookingProducts);
		final client = clientFactory.getClient();

		BookingResult result;
		String bookingError;

		try {
			result = await bookingRepository.saveOrUpdateBooking(client, bookingDetails, cabinsToSave, productsToSave);
			return new Tuple2(result, null);
		} catch (e) {
			if (e is AvailabilityException) {
				await cabins.refreshAvailability();
				await products.refreshAvailability();

				List<BookingCabin> savedCabins = null;
				List<BookingProduct> savedProducts = null;
				if (null != bookingResult) {
					// Try to get the last saved booking, then we can compare the number of cabins to see where avail failed
					try {
						final BookingSource lastSavedBooking = await bookingRepository.findBooking(client, bookingResult.reference);
						savedCabins = lastSavedBooking.cabins;
						savedProducts = lastSavedBooking.products;
					} catch (e) {
						print('Failed to retrieve prior booking for checking availability: ' + e.toString());
					}
				}

				bookingError = _getAvailabilityError(cabins, products, savedCabins, savedProducts);
			}
			else if (e is BookingException) {
				// Exception from backend, validation error (should not happen as we validate locally, but oh well)
				bookingError = 'Någonting gick fel när din bokning skulle sparas. Kontrollera att alla uppgifter är riktigt angivna och försök igen. Om problemet kvarstår, kontakta Sjöslaget.';
			} else {
				// Exception which is not coming from backend, potentially bad network
				bookingError = 'Någonting gick fel när din bokning skulle sparas. Kontrollera att du är ansluten till internet och försök igen. Om problemet kvarstår, kontakta Sjöslaget.';
			}
			print('Failed to save booking: ' + e.toString());
			return new Tuple2(null, bookingError);
		}
	}

	static String _getAvailabilityError(CabinsComponent cabins, ProductsComponent products,
		List<BookingCabin> savedCabins, List<BookingProduct> savedProducts) {
		// Calling this depends on having refreshed availability first

		bool hasCabinAvailabilityError = false;
		String error = '';
		for (CruiseCabin cabin in cabins.cruiseCabins) {
			final int available = cabins.getTotalAvailability(cabin.id);
			final int inBooking = cabins.getNumberOfCabinsInBooking(cabin.id);
			final int inSavedBooking = _getNumberOfCabinsOfType(savedCabins, cabin.id);

			if (available < inBooking) {
				hasCabinAvailabilityError = true;
				error += ' Det finns $inBooking hytt(er) av typen ${cabin.name} i bokningen, men det bara ${available + inSavedBooking} kvar att boka.';
			}
		}

		if (hasCabinAvailabilityError) {
			return 'Det finns inte tillräckligt många lediga hytter för att spara.' + error +
				' Ta bort hytter från bokningen eller byt till en annan typ och försök igen.';
		}

		bool hasProductAvailabilityError = false;
		error = '';
		for (CruiseProduct product in products.cruiseProducts) {
			final int available = products.getAvailability(product.id);
			final int inBooking = products.getQuantity(product.id);
			final int inSavedBooking = _getProductQuantity(savedProducts, product.id);

			if (available < inBooking) {
				hasProductAvailabilityError = true;
				error += ' Det finns $inBooking stycken \"${product.name}\" i bokningen, men det bara ${available + inSavedBooking} kvar att boka.';
			}
		}

		if (hasProductAvailabilityError) {
			return error + ' Ta bort tillägget från bokningen eller minska antalet.';
		} else {
			// Potential race condition, perhaps we have availability now but didn't when we tried to save
			return 'Någonting gick fel när bokningen skulle sparas. Försök igen.';
		}
	}

	static int _getNumberOfCabinsOfType
		(List<BookingCabin> cabins, String id) {
		if (null == cabins)
			return 0;

		return cabins
			.where((b) => b.cabinTypeId == id)
			.length;
	}

	static int _getProductQuantity
		(List<BookingProduct> products, String id) {
		if (null == products)
			return 0;

		BookingProduct product = products.firstWhere((p) => p.productTypeId == id, orElse: () => null);
		return product != null ? product.quantity : 0;
	}
}
