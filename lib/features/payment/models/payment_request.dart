
class PaymentRequest {
  final String bookingId;
  final String module;
  final String title;
  final int amountMinor;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;

  const PaymentRequest({
    required this.bookingId,
    required this.module,
    required this.title,
    required this.amountMinor,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
  });

  Map<String, dynamic> get customer => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
  };
}
