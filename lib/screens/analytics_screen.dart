import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../utils/constants.dart';
import '../utils/constants.dart';
import '../services/hive_service.dart';
import '../widgets/summary_card.dart';

/// Analytics screen with pie chart, bar chart, and summary
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expProvider = context.watch<ExpenseProvider>();
    final categorySpending = expProvider.categoryWiseSpending;
    final monthlyTrend = expProvider.monthlyTrend;
    final currency = HiveService.currency;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Cards ──
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Spent',
                    value:
                        '$currency${expProvider.totalSpentThisMonth.toStringAsFixed(0)}',
                    icon: Icons.trending_up_rounded,
                    gradientColors: const [
                      Color(0xFFA78BFA),
                      Color(0xFF6C63FF),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SummaryCard(
                    title: 'Transactions',
                    value: '${expProvider.expenses.length}',
                    icon: Icons.receipt_rounded,
                    gradientColors: const [
                      Color(0xFF4ECDC4),
                      Color(0xFF0ABD82),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Pie Chart ──
            Text(
              'Spending by Category',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: categorySpending.isEmpty
                    ? const SizedBox(
                        height: 200,
                        child: Center(child: Text('No data yet')),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 45,
                                sections: _buildPieSections(categorySpending),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Legend
                          Wrap(
                            spacing: 16,
                            runSpacing: 10,
                            children: categorySpending.keys.map((cat) {
                              final color =
                                  AppConstants.categoryColors[cat] ??
                                      Colors.grey;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Bar Chart ──
            Text(
              'Monthly Trends',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: monthlyTrend.values.every((v) => v == 0)
                    ? const SizedBox(
                        height: 200,
                        child: Center(child: Text('No data yet')),
                      )
                    : SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _maxBarValue(monthlyTrend) * 1.2,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex,
                                    rod, rodIndex) {
                                  return BarTooltipItem(
                                    '$currency${rod.toY.toStringAsFixed(0)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '$currency${value.toInt()}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final keys =
                                        monthlyTrend.keys.toList();
                                    if (value.toInt() < keys.length) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8),
                                        child: Text(
                                          keys[value.toInt()],
                                          style:
                                              const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval:
                                  _maxBarValue(monthlyTrend) / 4,
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups:
                                _buildBarGroups(monthlyTrend, context),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Weekly Spending ──
            Text(
              'Weekly Spending This Month',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (i) {
                    final weekly = expProvider.weeklySpending;
                    final max = weekly.reduce(
                        (a, b) => a > b ? a : b);
                    final heightFactor =
                        max > 0 ? weekly[i] / max : 0.0;
                    return Column(
                      children: [
                        Text(
                          '$currency${weekly[i].toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 28,
                          height: 100 * heightFactor.clamp(0.05, 1.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6C63FF),
                                Color(0xFFA78BFA),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'W${i + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map<String, double> categorySpending) {
    final total = categorySpending.values.fold(0.0, (a, b) => a + b);
    return categorySpending.entries.map((entry) {
      final pct = total > 0 ? (entry.value / total * 100) : 0.0;
      final color =
          AppConstants.categoryColors[entry.key] ?? Colors.grey;
      return PieChartSectionData(
        value: entry.value,
        title: '${pct.toStringAsFixed(0)}%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  double _maxBarValue(Map<String, double> trend) {
    if (trend.isEmpty) return 100;
    final max = trend.values.fold(0.0, (a, b) => a > b ? a : b);
    return max > 0 ? max : 100;
  }

  List<BarChartGroupData> _buildBarGroups(
      Map<String, double> trend, BuildContext context) {
    final entries = trend.entries.toList();
    return List.generate(entries.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: entries[i].value,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFA78BFA)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });
  }
}
