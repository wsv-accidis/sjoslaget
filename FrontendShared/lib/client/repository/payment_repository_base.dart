import 'dart:async';
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:http/http.dart';

import '../../admin/payment_history_provider.dart';
import '../../model/json_field.dart';
import '../../model/payment.dart';
import '../../model/payment_summary.dart';
import '../client_util.dart';
import '../http_status.dart';
import '../io_exception.dart';

class PaymentRepositoryBase implements PaymentHistoryProvider {
	final String _apiRoot;

	PaymentRepositoryBase(this._apiRoot);

	Future<List<Payment>> getPayments(Client client, String reference) async {
		Response response;
		try {
			response = await client.get('$_apiRoot/payments/$reference');
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		final List jsonResult = json.decode(response.body);
		return jsonResult
			.map((dynamic value) => Payment.fromMap(value))
			.toList();
	}

	Future<PaymentSummary> registerPayment(Client client, String reference, Decimal amount) async {
		final headers = ClientUtil.createJsonHeaders();
		final source = json.encode({AMOUNT: amount.toDouble()});

		Response response;
		try {
			response = await client.post('$_apiRoot/payments/pay/$reference', headers: headers, body: source);
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
		return PaymentSummary.fromJson(response.body);
	}

	Future<void> updateDiscount(Client client, String reference, int amount) async {
		final headers = ClientUtil.createJsonHeaders();
		final source = json.encode({AMOUNT: amount});

		Response response;
		try {
			response = await client.post('$_apiRoot/payments/discount/$reference', headers: headers, body: source);
		} catch (e) {
			throw IOException.fromException(e);
		}

		HttpStatus.throwIfNotSuccessful(response);
	}
}
