import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import 'app_config.dart';
import 'mock_data_store.dart';

/// Wraps Firebase Authentication + the `users` Firestore collection.
/// Registration/admin login for Infra-Jejak.
class AuthService {
  fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  AppUser? get currentUser {
    if (AppConfig.useMockBackend) return MockDataStore.instance.currentUser;
    final u = _auth.currentUser;
    if (u == null) return null;
    // In real mode, callers should prefer fetchUserProfile(uid) for full
    // profile data (role, name); this is a lightweight fallback.
    return AppUser(
      uid: u.uid,
      name: u.displayName ?? 'Infra Jejak User',
      email: u.email ?? '',
      role: UserRole.publicUser,
      createdAt: DateTime.now(),
    );
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (AppConfig.useMockBackend) {
      final user = AppUser(
        uid: MockDataStore.instance.newId(),
        name: name,
        email: email,
        role: UserRole.publicUser,
        createdAt: DateTime.now(),
      );
      MockDataStore.instance.users[user.uid] = user;
      MockDataStore.instance.currentUser = user;
      return user;
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = AppUser(
      uid: cred.user!.uid,
      name: name,
      email: email,
      role: UserRole.publicUser,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.uid).set(user.toFirestoreMap());
    return user;
  }

  Future<AppUser> login({required String email, required String password}) async {
    if (AppConfig.useMockBackend) {
      // Demo shortcut: logging in with "admin@infrajejak.my" signs in as admin.
      final isAdmin = email.trim().toLowerCase() == 'admin@infrajejak.my';
      final user = AppUser(
        uid: 'demo-user-1',
        name: isAdmin ? 'Infra Jejak Admin' : 'Demo Public User',
        email: email,
        role: isAdmin ? UserRole.admin : UserRole.publicUser,
        createdAt: DateTime.now(),
      );
      MockDataStore.instance.currentUser = user;
      return user;
    }

    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final doc = await _firestore.collection('users').doc(cred.user!.uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found. Please contact an administrator.');
    }
    return AppUser.fromFirestore(doc.id, doc.data()!);
  }

  Future<void> logout() async {
    if (AppConfig.useMockBackend) {
      MockDataStore.instance.currentUser = null;
      return;
    }
    await _auth.signOut();
  }
}
