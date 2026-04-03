import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';

/// Provider for managing budget state
class BudgetProvider extends ChangeNotifier {
  Budget? _currentBudget;

  Budget? get currentBudget => _currentBudget;
  double get monthlyLimit => _currentBudget?.monthlyLimit ?? 0.0;
  double get spentAmount => _currentBudget?.spentAmount ?? 0.0;
  double get remaining => _currentBudget?.remaining ?? 0.0;
  bool get isExceeded => _currentBudget?.isExceeded ?? false;
  double get percentage => _currentBudget?.percentage ?? 0.0;

  String get currentMonthKey => DateFormat('yyyy-MM').format(DateTime.now());

  /// Load budget for the current month
  void loadBudget() {
    _currentBudget = HiveService.getBudget(currentMonthKey);
    notifyListeners();
  }

  /// Set or update the monthly budget limit
  Future<void> setMonthlyLimit(double limit) async {
    if (_currentBudget != null) {
      _currentBudget!.monthlyLimit = limit;
      await HiveService.setBudget(_currentBudget!);
    } else {
      _currentBudget = Budget(
        monthlyLimit: limit,
        month: currentMonthKey,
      );
      await HiveService.setBudget(_currentBudget!);
    }
    notifyListeners();

    // Sync to Firestore
    try {
      await FirebaseService.syncBudgetToCloud(_currentBudget!.toMap());
    } catch (_) {}
  }

  /// Update the spent amount (called whenever expenses change)
  Future<void> updateSpentAmount(double totalSpent) async {
    if (_currentBudget != null) {
      _currentBudget!.spentAmount = totalSpent;
      await HiveService.setBudget(_currentBudget!);
    } else {
      _currentBudget = Budget(
        monthlyLimit: 0,
        spentAmount: totalSpent,
        month: currentMonthKey,
      );
      await HiveService.setBudget(_currentBudget!);
    }
    notifyListeners();

    // Sync to Firestore
    try {
      await FirebaseService.syncBudgetToCloud(_currentBudget!.toMap());
    } catch (_) {}
  }

  /// Check if budget alert should be shown
  bool get shouldShowAlert {
    if (_currentBudget == null || _currentBudget!.monthlyLimit <= 0) {
      return false;
    }
    return _currentBudget!.percentage >= 0.9; // Alert at 90%
  }
}
