enum UserRole { publicUser, admin }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? 'Infra Jejak User',
      email: data['email'] as String? ?? '',
      role: (data['role'] as String?) == 'admin'
          ? UserRole.admin
          : UserRole.publicUser,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (data['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'publicUser',
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
