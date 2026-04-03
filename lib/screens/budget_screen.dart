import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';

/// Screen to set/view the monthly budget
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();
  String _selectedCurrency = HiveService.currency;

  @override
  void initState() {
    super.initState();
    final budget = context.read<BudgetProvider>().monthlyLimit;
    if (budget > 0) {
      _budgetController.text = budget.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final value = double.tryParse(_budgetController.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    await HiveService.setCurrency(_selectedCurrency);
    await context.read<BudgetProvider>().setMonthlyLimit(value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Budget saved successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final expProvider = context.watch<ExpenseProvider>();
    final currency = _selectedCurrency;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Budget Status Card ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Circular progress
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value:
                                  budgetProvider.percentage.clamp(0.0, 1.0),
                              strokeWidth: 12,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation(
                                budgetProvider.isExceeded
                                    ? Colors.red
                                    : budgetProvider.percentage > 0.8
                                        ? Colors.orange
                                        : const Color(0xFF4ECDC4),
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(budgetProvider.percentage * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'used',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BudgetStat(
                          label: 'Budget',
                          value:
                              '$currency${budgetProvider.monthlyLimit.toStringAsFixed(0)}',
                          color: Colors.blue,
                        ),
                        _BudgetStat(
                          label: 'Spent',
                          value:
                              '$currency${budgetProvider.spentAmount.toStringAsFixed(0)}',
                          color: Colors.red,
                        ),
                        _BudgetStat(
                          label: 'Remaining',
                          value:
                              '$currency${budgetProvider.remaining.toStringAsFixed(0)}',
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Set Budget ──
            Text(
              'Set Monthly Budget',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Currency selector
            Row(
              children: [
                Text(
                  'Currency: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                ...AppConstants.currencies.map((c) {
                  final isSelected = _selectedCurrency == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCurrency = c),
                      child: Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(30)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 18),

            TextFormField(
              controller: _budgetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Enter monthly budget',
                prefixText: '$currency ',
                prefixStyle: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveBudget,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Budget'),
              ),
            ),

            // ── Category Breakdown ──
            const SizedBox(height: 32),
            Text(
              'Category Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ...expProvider.categoryWiseSpending.entries.map((entry) {
              final total = expProvider.totalSpentThisMonth;
              final pct = total > 0 ? entry.value / total : 0.0;
              final color =
                  AppConstants.categoryColors[entry.key] ?? Colors.grey;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Text(entry.key,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: color.withAlpha(30),
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$currency${entry.value.toStringAsFixed(0)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BudgetStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
