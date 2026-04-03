import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Firebase service for Authentication and Firestore cloud sync.
///
/// ⚠️ REQUIRES Firebase project setup — see FIREBASE_SETUP.md for steps.
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Authentication ───────────────────────────────────────

  /// Sign in with email & password
  static Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        return UserModel(uid: user.uid, email: user.email ?? email);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    }
  }

  /// Register a new user with email & password
  static Future<UserModel?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return UserModel(uid: user.uid, email: user.email ?? email);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e.code);
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get currently signed-in user
  static UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      return UserModel(uid: user.uid, email: user.email ?? '');
    }
    return null;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  /// Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Firestore: Expenses ──────────────────────────────────

  /// Get the expenses collection reference for the current user
  static CollectionReference<Map<String, dynamic>> _expensesRef() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  /// Sync a list of local expenses to Firestore
  static Future<void> syncExpensesToCloud(
      List<Map<String, dynamic>> expenses) async {
    if (!isAuthenticated) return;

    final batch = _firestore.batch();
    for (final expense in expenses) {
      final docRef = _expensesRef().doc(expense['id']);
      batch.set(docRef, expense, SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Fetch all expenses from Firestore for the current user
  static Future<List<Map<String, dynamic>>> fetchExpensesFromCloud() async {
    if (!isAuthenticated) return [];

    final snapshot = await _expensesRef()
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Delete an expense from Firestore
  static Future<void> deleteExpenseFromCloud(String expenseId) async {
    if (!isAuthenticated) return;
    await _expensesRef().doc(expenseId).delete();
  }

  // ─── Firestore: Budget ────────────────────────────────────

  /// Get the budgets collection reference for the current user
  static CollectionReference<Map<String, dynamic>> _budgetsRef() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('budgets');
  }

  /// Sync budget to Firestore
  static Future<void> syncBudgetToCloud(Map<String, dynamic> budget) async {
    if (!isAuthenticated) return;
    await _budgetsRef().doc(budget['month']).set(budget, SetOptions(merge: true));
  }

  /// Fetch budget from Firestore for a given month
  static Future<Map<String, dynamic>?> fetchBudgetFromCloud(
      String month) async {
    if (!isAuthenticated) return null;

    final doc = await _budgetsRef().doc(month).get();
    return doc.exists ? doc.data() : null;
  }

  // ─── Error Mapping ────────────────────────────────────────

  static String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
