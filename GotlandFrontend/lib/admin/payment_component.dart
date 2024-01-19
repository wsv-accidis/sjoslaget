import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/model/payment_summary.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/client_factory.dart';
import '../client/payment_repository.dart';
import '../widgets/components.dart';

@Component(
    selector: 'payment-component',
    templateUrl: 'payment_component.html',
    styleUrls: ['../content/content_styles.css', 'payment_component.css'],
    directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives, materialNumberInputDirectives])
class PaymentComponent {
  final ClientFactory _clientFactory;
  final PaymentRepository _paymentRepository;
  final _onDiscountUpdated = StreamController<int>.broadcast();
  final _onPaymentUpdated = StreamController<PaymentSummary>.broadcast();

  @Input()
  set bookingDiscount(int value) {
    discount = value.toString();
    discountPercent = value;
    _calculatePayment();
  }

  @Input()
  String bookingRef;

  @Input()
  PaymentSummary bookingPayment;

  @Input()
  int price = 0;

  @Input()
  bool readOnly = false;

  @Output()
  Stream<int> get onDiscountUpdated => _onDiscountUpdated.stream;

  @Output()
  Stream<PaymentSummary> get onPaymentUpdated => _onPaymentUpdated.stream;

  String discount;
  int discountPercent = 0;
  bool isSaving = false;
  String payment;
  String paymentError;

  PaymentComponent(this._clientFactory, this._paymentRepository);

  Decimal get amountPaid => bookingPayment != null ? bookingPayment.total : 0;

  String get amountPaidFormatted => CurrencyFormatter.formatDecimalAsSEK(hasPayment ? amountPaid : 0);

  Decimal get discountValue {
    final priceAsDec = Decimal.fromInt(price);
    final discountAsDec = Decimal.fromInt(discountPercent) / Decimal.fromInt(100);
    return priceAsDec * discountAsDec;
  }

  String get discountValueFormatted => CurrencyFormatter.formatDecimalAsSEK(discountValue);

  bool get hasDiscount => discountPercent > 0;

  bool get hasPayment => null != amountPaid && amountPaid.ceilToDouble() > 0.0;

  bool get hasPaymentError => isNotEmpty(paymentError);

  bool get hasPrice => price > 0;

  String get latestPaymentFormatted => null != bookingPayment ? DateTimeFormatter.format(bookingPayment.latest) : '';

  String get priceFormatted => CurrencyFormatter.formatIntAsSEK(price);

  Decimal get priceRemaining => hasPayment ? priceWithDiscount - amountPaid : priceWithDiscount;

  String get priceRemainingFormatted => CurrencyFormatter.formatDecimalAsSEK(priceRemaining);

  Decimal get priceWithDiscount => Decimal.fromInt(price) - discountValue;

  String get priceWithDiscountFormatted => CurrencyFormatter.formatDecimalAsSEK(priceWithDiscount);

  Future<void> registerPayment() async {
    if (isSaving || readOnly) return;

    isSaving = true;
    paymentError = null;

    try {
      final Decimal paymentDec = ValueConverter.parseDecimal(payment);
      if (null == paymentDec) {
        paymentError =
            'Felaktigt belopp. Kontrollera att fältet bara innehåller siffror, eventuellt minustecken och decimalpunkt.';
        return;
      }

      try {
        final client = _clientFactory.getClient();
        final PaymentSummary result = await _paymentRepository.registerPayment(client, bookingRef, paymentDec);

        bookingPayment = result;
        _onPaymentUpdated.add(result);

        _calculatePayment();
      } catch (e) {
        print('Failed to register payment: ${e.toString()}');
        paymentError = 'Någonting gick fel när betalningen skulle registreras. Försök igen.';
      }
    } finally {
      isSaving = false;
    }
  }

  Future<void> updateDiscount() async {
    if (isSaving || readOnly) return;

    isSaving = true;
    paymentError = null;

    try {
      int discountInt;
      try {
        discountInt = int.parse(discount.replaceAll('%', ''));
      } catch (e) {
        print('Exception parsing discount amount: ${e.toString()}');
        paymentError = 'Felaktig rabatt. Kontrollera att fältet bara innehåller siffror.';
        return;
      }

      try {
        final client = _clientFactory.getClient();
        await _paymentRepository.updateDiscount(client, bookingRef, discountInt);

        discount = discountInt.toString();
        discountPercent = discountInt;
        _onDiscountUpdated.add(discountInt);
      } catch (e) {
        print('Failed to update discount: ${e.toString()}');
        paymentError = 'Någonting gick fel när rabatten skulle sparas. Försök igen.';
      }
    } finally {
      isSaving = false;
    }
  }

  void _calculatePayment() {
    if (priceRemaining.ceilToDouble() > 0.0) {
      payment = CurrencyFormatter.formatDecimalForInput(priceRemaining);
    } else {
      payment = '0';
    }
  }
}
