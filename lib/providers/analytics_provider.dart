import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'transaction_provider.dart';
import 'pantry_provider.dart';

class AnalyticsData {
  final Map<String, double> salesTrend;
  final Map<String, double> expenseTrend;
  final List<String> trendDates;
  final Map<String, int> inventoryDistribution;
  final double totalMonthlySales;
  final double totalMonthlyExpenses;

  AnalyticsData({
    required this.salesTrend,
    required this.expenseTrend,
    required this.trendDates,
    required this.inventoryDistribution,
    required this.totalMonthlySales,
    required this.totalMonthlyExpenses,
  });
}

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final transactions = ref.watch(transactionProvider);
  final pantryItems = ref.watch(pantryProvider);

  // 1. Calculate 7-day trends
  final now = DateTime.now();
  final Map<String, double> salesMap = {};
  final Map<String, double> expensesMap = {};
  final List<String> dates = [];

  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dateStr = DateFormat('MM/dd').format(date);
    dates.add(dateStr);
    salesMap[dateStr] = 0;
    expensesMap[dateStr] = 0;
  }

  for (final tx in transactions) {
    final dateStr = DateFormat('MM/dd').format(tx.date);
    if (salesMap.containsKey(dateStr)) {
      if (tx.type == 'sale') {
        salesMap[dateStr] = (salesMap[dateStr] ?? 0) + tx.amount;
      } else {
        expensesMap[dateStr] = (expensesMap[dateStr] ?? 0) + tx.amount;
      }
    }
  }

  // 2. Calculate Inventory Distribution
  final Map<String, int> categoryCounts = {};
  for (final item in pantryItems) {
    categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
  }

  // 3. Calculate Monthly Overview
  final totalSales = transactions
      .where((t) => t.type == 'sale')
      .fold(0.0, (sum, t) => sum + t.amount);
  final totalExpenses = transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  return AnalyticsData(
    salesTrend: salesMap,
    expenseTrend: expensesMap,
    trendDates: dates,
    inventoryDistribution: categoryCounts,
    totalMonthlySales: totalSales,
    totalMonthlyExpenses: totalExpenses,
  );
});
