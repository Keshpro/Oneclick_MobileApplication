<<<<<<< Updated upstream
enum UserRole { admin, doctor, patient, driver, passenger }
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
=======
class UserModel {
  const UserModel({required this.id, required this.name});

  final String id;
  final String name;
}
>>>>>>> Stashed changes
