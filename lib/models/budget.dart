import 'package:hive/hive.dart';

part 'budget.g.dart';

/// Budget data model stored locally via Hive
@HiveType(typeId: 1)
class Budget extends HiveObject {
  @HiveField(0)
  double monthlyLimit;

  @HiveField(1)
  double spentAmount;

  @HiveField(2)
  String month; // Format: 'yyyy-MM'

  Budget({
    required this.monthlyLimit,
    this.spentAmount = 0.0,
    required this.month,
  });

  double get remaining => monthlyLimit - spentAmount;
  bool get isExceeded => spentAmount > monthlyLimit;
  double get percentage =>
      monthlyLimit > 0 ? (spentAmount / monthlyLimit).clamp(0.0, 1.5) : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'monthlyLimit': monthlyLimit,
      'spentAmount': spentAmount,
      'month': month,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      monthlyLimit: (map['monthlyLimit'] as num).toDouble(),
      spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0.0,
      month: map['month'] as String,
    );
  }
}
