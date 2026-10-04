
enum UserRole { admin, doctor, patient, driver, passenger, customer }
enum AccountStatus { pending, approved, rejected }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final AccountStatus status;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
  });
}


