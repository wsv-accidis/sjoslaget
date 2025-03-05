import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import '../model/day_booking_capacity.dart';
import '../model/day_booking_list_item.dart';
import '../model/day_booking_source.dart';
import '../model/day_booking_type.dart';
import 'booking_exception.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;
import 'duplicate_booking_exception.dart';
import 'sold_out_exception.dart';

@Injectable()
class DayBookingRepository {
  final String _apiRoot;

  DayBookingRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

  Future<void> confirmBooking(Client client, String reference) async {
    Response response;
    try {
      response = await client.put('$_apiRoot/daybookings/confirm/$reference');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
  }

  Future<void> deleteBooking(Client client, String reference) async {
    Response response;
    try {
      response = await client.delete('$_apiRoot/daybookings/$reference');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
  }

  Future<DayBookingSource> getBooking(Client client, String id) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/daybookings/$id');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    return DayBookingSource.fromJson(response.body);
  }

  Future<List<DayBookingListItem>> getList(Client client) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/daybookings/list');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    final List jsonBody = json.decode(response.body);
    return jsonBody.map((dynamic value) => DayBookingListItem.fromMap(value)).toList();
  }

  Future<DayBookingCapacity> getCapacity(Client client) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/daybookings/capacity');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    return DayBookingCapacity.fromJson(response.body);
  }

  Future<List<DayBookingType>> getTypes(Client client) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/daybookings/types');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    final List jsonBody = json.decode(response.body);
    return jsonBody.map((dynamic value) => DayBookingType.fromMap(value)).toList();
  }

  Future<void> createBooking(Client client, DayBookingSource booking) async {
    final headers = ClientUtil.createJsonHeaders();

    Response response;
    try {
      response = await client.post('$_apiRoot/daybookings/create', headers: headers, body: booking.toJson());
    } catch (e) {
      throw IOException.fromException(e);
    }

    if (HttpStatus.OK == response.statusCode)
      return;
    else if (HttpStatus.BAD_REQUEST == response.statusCode)
      throw BookingException();
    else if (HttpStatus.CONFLICT == response.statusCode)
      throw SoldOutException();
    else if (HttpStatus.EXPECTATION_FAILED == response.statusCode)
      throw DuplicateBookingException();
    else
      throw IOException.fromResponse(response);
  }

  Future<void> saveBooking(Client client, DayBookingSource booking) async {
    final headers = ClientUtil.createJsonHeaders();

    Response response;
    try {
      response = await client.post('$_apiRoot/daybookings/update', headers: headers, body: booking.toJson());
    } catch (e) {
      throw IOException.fromException(e);
    }

    if (HttpStatus.OK == response.statusCode)
      return;
    else if (HttpStatus.BAD_REQUEST == response.statusCode)
      throw BookingException();
    else
      throw IOException.fromResponse(response);
  }
}
