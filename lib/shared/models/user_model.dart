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

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.patient,
      ),
      status: AccountStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AccountStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'status': status.name,
    };
  }
}