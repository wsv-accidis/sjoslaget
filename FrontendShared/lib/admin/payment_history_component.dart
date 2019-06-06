import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' show isEmpty;

import '../client/client_provider.dart';
import '../model/payment.dart';
import '../util/currency_formatter.dart';
import '../util/datetime_formatter.dart';
import 'payment_history_provider.dart';

@Component(
	selector: 'payment-history-component-popup',
	styleUrls: ['payment_history_component.css'],
	templateUrl: 'payment_history_component_popup.html',
	directives: <dynamic>[coreDirectives]
)
class PaymentHistoryComponentPopup implements OnInit {
	final ClientProvider _clientProvider;
	final PaymentHistoryProvider _paymentHistoryProvider;

	@Input()
	String bookingRef;

	bool isLoading = false;
	List<Payment> payments = <Payment>[];

	bool get hasPayments => payments.isNotEmpty;

	PaymentHistoryComponentPopup(this._clientProvider, this._paymentHistoryProvider);

	@override
	Future<void> ngOnInit() async {
		if (isEmpty(bookingRef)) {
			return;
		}

		isLoading = true;
		try {
			final client = _clientProvider.getClient();
			payments = await _paymentHistoryProvider.getPayments(client, bookingRef);
		} catch (e) {
			print('Failed to load payments: ${e.toString()}');
		} finally {
			isLoading = false;
		}
	}

	String formatAmount(Decimal amount) => CurrencyFormatter.formatDecimalAsSEK(amount);

	String formatCreated(DateTime created) => DateTimeFormatter.format(created);
}

@Component(
	selector: 'payment-history-component',
	styleUrls: ['payment_history_component.css'],
	templateUrl: 'payment_history_component.html',
	directives: <dynamic>[DeferredContentDirective, MaterialExpansionPanel, PaymentHistoryComponentPopup]
)
class PaymentHistoryComponent {
	@Input()
	String bookingRef;
}
