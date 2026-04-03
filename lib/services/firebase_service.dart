import '../models/user_model.dart';

/// Stub Firebase service — works without Firebase configuration.
/// Replace with real Firebase calls when google-services.json is added.
class FirebaseService {
  static UserModel? _currentUser;

  /// Simulated sign-in with email & password
  static Future<UserModel?> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Stub: accept any non-empty credentials
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        uid: 'local_${email.hashCode}',
        email: email,
      );
      return _currentUser;
    }
    return null;
  }

  /// Simulated registration
  static Future<UserModel?> register(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        uid: 'local_${email.hashCode}',
        email: email,
      );
      return _currentUser;
    }
    return null;
  }

  /// Sign out
  static Future<void> signOut() async {
    _currentUser = null;
  }

  /// Get current user
  static UserModel? get currentUser => _currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => _currentUser != null;

  // ─── Firestore Sync Stubs ─────────────────────────────────

  /// Sync local expenses to Firestore (stub)
  static Future<void> syncExpensesToCloud(List<Map<String, dynamic>> expenses) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with real Firestore batch write
    // final batch = FirebaseFirestore.instance.batch();
    // for (final e in expenses) {
    //   batch.set(
    //     FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(_currentUser!.uid)
    //         .collection('expenses')
    //         .doc(e['id']),
    //     e,
    //   );
    // }
    // await batch.commit();
  }

  /// Sync budget to Firestore (stub)
  static Future<void> syncBudgetToCloud(Map<String, dynamic> budget) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Replace with real Firestore write
  }
}
