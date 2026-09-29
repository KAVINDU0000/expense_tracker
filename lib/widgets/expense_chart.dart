import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/categories.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  const ExpenseChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No data for this month yet.')),
      );
    }

    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final currency = context.watch<CurrencyProvider>().formatter;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: entries.map((e) {
                final cat = categoryFromName(e.key);
                final percent = (e.value / total * 100);
                return PieChartSectionData(
                  color: cat.color,
                  value: e.value,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: 55,
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...entries.map((e) {
          final cat = categoryFromName(e.key);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(radius: 5, backgroundColor: cat.color),
                const SizedBox(width: 8),
                Expanded(child: Text(e.key)),
                Text(currency.format(e.value),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
