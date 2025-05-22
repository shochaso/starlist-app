import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:starlist/src/features/payment/models/payment_model.dart";
import "package:starlist/src/features/payment/providers/payment_provider.dart";
import "package:starlist/src/features/payment/services/payment_service.dart";

class MockPaymentService extends Mock implements PaymentService {}

void main() {
  late PaymentProvider provider;
  late MockPaymentService mockService;

  setUp(() {
    mockService = MockPaymentService();
    provider = PaymentProvider(mockService);
  });

  test("initial state", () {
    expect(provider.payments, isEmpty);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("create payment", () async {
    final payment = PaymentModel(
      id: "test-id",
      userId: "user-id",
      amount: 1000,
      currency: "JPY",
      status: PaymentStatus.pending,
      method: PaymentMethod.creditCard,
      createdAt: DateTime.now(),
    );

    when(mockService.createPayment(
      userId: "user-id",
      amount: 1000,
      currency: "JPY",
      paymentMethodId: "payment-method-id",
    )).thenAnswer((_) async => payment);

    await provider.createPayment(
      userId: "user-id",
      amount: 1000,
      currency: "JPY",
      paymentMethodId: "payment-method-id",
    );

    expect(provider.payments.length, 1);
    expect(provider.payments.first.id, "test-id");
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load user payments", () async {
    final payments = [
      PaymentModel(
        id: "test-id-1",
        userId: "user-id",
        amount: 1000,
        currency: "JPY",
        status: PaymentStatus.completed,
        method: PaymentMethod.creditCard,
        createdAt: DateTime.now(),
      ),
      PaymentModel(
        id: "test-id-2",
        userId: "user-id",
        amount: 2000,
        currency: "JPY",
        status: PaymentStatus.completed,
        method: PaymentMethod.creditCard,
        createdAt: DateTime.now(),
      ),
    ];

    when(mockService.getUserPayments("user-id")).thenAnswer((_) async => payments);

    await provider.loadUserPayments("user-id");

    expect(provider.payments.length, 2);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("cancel payment", () async {
    final payment = PaymentModel(
      id: "test-id",
      userId: "user-id",
      amount: 1000,
      currency: "JPY",
      status: PaymentStatus.canceled,
      method: PaymentMethod.creditCard,
      createdAt: DateTime.now(),
    );

    when(mockService.cancelPayment("test-id")).thenAnswer((_) async => payment);

    provider._payments = [payment];
    await provider.cancelPayment("test-id");

    expect(provider.payments.first.status, PaymentStatus.canceled);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("refund payment", () async {
    final payment = PaymentModel(
      id: "test-id",
      userId: "user-id",
      amount: 1000,
      currency: "JPY",
      status: PaymentStatus.refunded,
      method: PaymentMethod.creditCard,
      createdAt: DateTime.now(),
    );

    when(mockService.refundPayment("test-id")).thenAnswer((_) async => payment);

    provider._payments = [payment];
    await provider.refundPayment("test-id");

    expect(provider.payments.first.status, PaymentStatus.refunded);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });
}
