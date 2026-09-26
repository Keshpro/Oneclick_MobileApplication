import '../../shared/models/user_model.dart';

class AdminService {
  // Dummy Users List (UI Test කිරීම සඳහා)
  static List<UserModel> dummyUsers = [
    UserModel(
      uid: '1',
      name: 'Kamal Perera',
      email: 'kamal@gmail.com',
      role: UserRole.doctor,
      status: AccountStatus.pending,
    ),
    UserModel(
      uid: '2',
      name: 'Nimal Silva',
      email: 'nimal@gmail.com',
      role: UserRole.driver,
      status: AccountStatus.pending,
    ),
    UserModel(
      uid: '3',
      name: 'Sunil Fernando',
      email: 'sunil@gmail.com',
      role: UserRole.patient,
      status: AccountStatus.approved,
    ),
  ];

  List<UserModel> getPendingUsers() {
    return dummyUsers.where((u) => u.status == AccountStatus.pending).toList();
  }

  List<UserModel> getAllUsers() {
    return dummyUsers;
  }
}
