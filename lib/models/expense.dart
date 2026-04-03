import 'package:hive/hive.dart';

part 'expense.g.dart';

/// Category options for expenses
enum ExpenseCategory {
  food,
  travel,
  bills,
  shopping,
  entertainment,
  health,
  education,
  other,
}

/// Expense data model stored locally via Hive
@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String note;

  @HiveField(5)
  bool isSynced;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    this.isSynced = false,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    bool? isSynced,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'isSynced': isSynced,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }
}
