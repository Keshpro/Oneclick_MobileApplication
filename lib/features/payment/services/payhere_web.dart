
import 'dart:js_interop';

@JS('oneclickPayHere')
external JSPromise<JSString> _openPayHere(JSAny payment);

Future<void> openPayHereWeb(
  Map<String, dynamic> payment,
) async {
  final jsPayment = payment.jsify();

  if (jsPayment == null) {
    throw StateError('Invalid payment information.');
  }

  await _openPayHere(jsPayment).toDart;
}
