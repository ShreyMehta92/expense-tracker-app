import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/expense_card.dart';
import '../services/hive_service.dart';

/// Main home/dashboard screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
      context.read<BudgetProvider>().loadBudget();
      _syncBudgetSpent();
    });
  }

  void _syncBudgetSpent() {
    final expProvider = context.read<ExpenseProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    budgetProvider.updateSpentAmount(expProvider.totalSpentThisMonth);
  }

  void _onTabChanged(int index) {
    if (index == 0) {
      setState(() => _currentIndex = 0);
    } else if (index == 1) {
      Navigator.pushNamed(context, '/expenses');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/add');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/analytics');
    } else if (index == 4) {
      Navigator.pushNamed(context, '/budget');
    }
  }

  @override
  Widget build(BuildContext context) {
    final expProvider = context.watch<ExpenseProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final currency = HiveService.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          expProvider.loadExpenses();
          budgetProvider.loadBudget();
          _syncBudgetSpent();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting Section ──
              Text(
                'Hello! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(150),
                    ),
              ),
              const SizedBox(height: 22),

              // ── Summary Cards ──
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Total Spent',
                      value:
                          '$currency${expProvider.totalSpentThisMonth.toStringAsFixed(0)}',
                      icon: Icons.arrow_upward_rounded,
                      gradientColors: const [
                        Color(0xFFFF6B6B),
                        Color(0xFFEE5A24),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SummaryCard(
                      title: 'Remaining',
                      value:
                          '$currency${budgetProvider.remaining.toStringAsFixed(0)}',
                      icon: Icons.savings_rounded,
                      gradientColors: [
                        budgetProvider.isExceeded
                            ? const Color(0xFFCF6679)
                            : const Color(0xFF4ECDC4),
                        budgetProvider.isExceeded
                            ? Colors.red.shade700
                            : const Color(0xFF0ABD82),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Budget Progress ──
              if (budgetProvider.monthlyLimit > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$currency${budgetProvider.spentAmount.toStringAsFixed(0)} / $currency${budgetProvider.monthlyLimit.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: budgetProvider.percentage.clamp(0.0, 1.0),
                            minHeight: 10,
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
                          ),
                        ),
                        if (budgetProvider.shouldShowAlert) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_rounded,
                                    color: Colors.red.shade400, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    budgetProvider.isExceeded
                                        ? 'Budget exceeded! Review your spending.'
                                        : 'Almost at budget limit!',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // ── Recent Expenses ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Expenses',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/expenses'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (expProvider.recentExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 56,
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                ?.withAlpha(80)),
                        const SizedBox(height: 12),
                        Text(
                          'No expenses yet.\nTap + to add your first expense!',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withAlpha(100),
                                  ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...expProvider.recentExpenses.map((e) => ExpenseCard(
                      expense: e,
                      currency: currency,
                      onTap: () => Navigator.pushNamed(context, '/add',
                          arguments: e),
                      onDelete: () {
                        expProvider.deleteExpense(e.id);
                        _syncBudgetSpent();
                      },
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/add').then((_) => _syncBudgetSpent()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}
