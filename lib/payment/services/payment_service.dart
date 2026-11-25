
import '../models/payment_request.dart';

enum PaymentStatus {
  pending,
  processing,
  paid,
  failed,
  cancelled,
  refunded,
}

class PaymentSession {
  final String paymentId;
  final String orderId;
  final String checkoutReference;

  const PaymentSession({
    required this.paymentId,
    required this.orderId,
    required this.checkoutReference,
  });
}

abstract class PaymentService {
  // Must call a trusted backend:
  // - authenticate user
  // - verify order ownership
  // - calculate total from stored order
  // - create/reuse payment attempt
  // - return gateway checkout parameters
  Future<PaymentSession> createPaymentSession(
    PaymentRequest request,
  );

  // Status must come from backend verification,
  // never from a success button in the Flutter UI.
  Future<PaymentStatus> getPaymentStatus(
    String paymentId,
  );
}
