import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/budget.dart';

/// Service that manages all Hive local storage operations
class HiveService {
  static const String expenseBoxName = 'expenses';
  static const String budgetBoxName = 'budgets';
  static const String settingsBoxName = 'settings';

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(BudgetAdapter());

    // Open boxes
    await Hive.openBox<Expense>(expenseBoxName);
    await Hive.openBox<Budget>(budgetBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // ─── Expense Operations ───────────────────────────────────

  static Box<Expense> get _expenseBox => Hive.box<Expense>(expenseBoxName);

  /// Get all expenses sorted by date (newest first)
  static List<Expense> getAllExpenses() {
    final expenses = _expenseBox.values.toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  /// Add a new expense
  static Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  /// Update an existing expense
  static Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  /// Delete an expense by id
  static Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  /// Get expenses for a specific month (format: yyyy-MM)
  static List<Expense> getExpensesForMonth(String month) {
    return getAllExpenses().where((e) {
      final expMonth =
          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      return expMonth == month;
    }).toList();
  }

  // ─── Budget Operations ────────────────────────────────────

  static Box<Budget> get _budgetBox => Hive.box<Budget>(budgetBoxName);

  /// Get budget for a specific month
  static Budget? getBudget(String month) {
    return _budgetBox.get(month);
  }

  /// Set or update budget for a month
  static Future<void> setBudget(Budget budget) async {
    await _budgetBox.put(budget.month, budget);
  }

  // ─── Settings Operations ──────────────────────────────────

  static Box get _settingsBox => Hive.box(settingsBoxName);

  static bool get isDarkMode => _settingsBox.get('isDarkMode', defaultValue: false);
  static Future<void> setDarkMode(bool value) async {
    await _settingsBox.put('isDarkMode', value);
  }

  static String get currency => _settingsBox.get('currency', defaultValue: '₹');
  static Future<void> setCurrency(String value) async {
    await _settingsBox.put('currency', value);
  }
}
