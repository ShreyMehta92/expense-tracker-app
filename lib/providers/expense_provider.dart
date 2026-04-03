import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';

/// Provider for managing expenses state and CRUD operations
class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  String _searchQuery = '';
  String _filterCategory = 'All';
  DateTime _selectedMonth = DateTime.now();

  // ─── Getters ──────────────────────────────────────────────

  List<Expense> get expenses => _filteredExpenses;
  List<Expense> get allExpenses => _expenses;
  String get searchQuery => _searchQuery;
  String get filterCategory => _filterCategory;
  DateTime get selectedMonth => _selectedMonth;
  String get currentMonthKey =>
      DateFormat('yyyy-MM').format(_selectedMonth);

  List<Expense> get _filteredExpenses {
    var result = List<Expense>.from(_expenses);

    // Filter by selected month
    result = result.where((e) {
      return e.date.year == _selectedMonth.year &&
          e.date.month == _selectedMonth.month;
    }).toList();

    // Filter by category
    if (_filterCategory != 'All') {
      result = result.where((e) => e.category == _filterCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) {
        return e.note.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q) ||
            e.amount.toString().contains(q);
      }).toList();
    }

    return result;
  }

  /// Total spent in the selected month
  double get totalSpentThisMonth {
    return _expenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Category-wise spending for the selected month
  Map<String, double> get categoryWiseSpending {
    final map = <String, double>{};
    for (final e in _expenses.where((e) =>
        e.date.year == _selectedMonth.year &&
        e.date.month == _selectedMonth.month)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  /// Weekly spending for the selected month (4-5 weeks)
  List<double> get weeklySpending {
    final weeks = List.filled(5, 0.0);
    for (final e in _expenses.where((e) =>
        e.date.year == _selectedMonth.year &&
        e.date.month == _selectedMonth.month)) {
      final weekIndex = ((e.date.day - 1) / 7).floor().clamp(0, 4);
      weeks[weekIndex] += e.amount;
    }
    return weeks;
  }

  /// Monthly totals for the last 6 months
  Map<String, double> get monthlyTrend {
    final map = <String, double>{};
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(
          _selectedMonth.year, _selectedMonth.month - i, 1);
      final key = DateFormat('MMM').format(month);
      map[key] = _expenses
          .where((e) =>
              e.date.year == month.year && e.date.month == month.month)
          .fold(0.0, (sum, e) => sum + e.amount);
    }
    return map;
  }

  /// Recent 5 expenses
  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  // ─── Actions ──────────────────────────────────────────────

  /// Load all expenses from Hive
  void loadExpenses() {
    _expenses = HiveService.getAllExpenses();
    notifyListeners();
  }

  /// Add a new expense (saves to Hive + syncs to Firestore)
  Future<void> addExpense({
    required double amount,
    required String category,
    required DateTime date,
    String note = '',
  }) async {
    final expense = Expense(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      date: date,
      note: note,
    );
    await HiveService.addExpense(expense);
    _expenses.add(expense);
    notifyListeners();

    // Sync to Firestore in background
    try {
      await FirebaseService.syncExpensesToCloud([expense.toMap()]);
    } catch (_) {
      // Offline — will sync later
    }
  }

  /// Update an existing expense (Hive + Firestore)
  Future<void> updateExpense(Expense expense) async {
    await HiveService.updateExpense(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }

    // Sync update to Firestore
    try {
      await FirebaseService.syncExpensesToCloud([expense.toMap()]);
    } catch (_) {}
  }

  /// Delete an expense (Hive + Firestore)
  Future<void> deleteExpense(String id) async {
    await HiveService.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();

    // Delete from Firestore
    try {
      await FirebaseService.deleteExpenseFromCloud(id);
    } catch (_) {}
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set category filter
  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  /// Set selected month
  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }
}
