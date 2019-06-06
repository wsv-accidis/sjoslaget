import 'dart:async';

import 'package:http/http.dart';

import '../model/payment.dart';

abstract class PaymentHistoryProvider {
	Future<List<Payment>> getPayments(Client client, String reference);
}
