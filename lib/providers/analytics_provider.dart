import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'transaction_provider.dart';
import 'pantry_provider.dart';
import '../models/transaction.dart';

enum AnalyticsPeriod { day, week, month, year }

class AnalyticsData {
  final Map<String, double> salesTrend;
  final Map<String, double> expenseTrend;
  final List<String> trendDates;
  final Map<String, int> inventoryDistribution;
  final double totalSales;
  final double totalExpenses;
  final double previousSales;
  final double previousExpenses;
  final AnalyticsPeriod period;
  final String? topExpenseCategory;
  final List<BusinessTransaction> periodTransactions;

  AnalyticsData({
    required this.salesTrend,
    required this.expenseTrend,
    required this.trendDates,
    required this.inventoryDistribution,
    required this.totalSales,
    required this.totalExpenses,
    required this.previousSales,
    required this.previousExpenses,
    required this.period,
    this.topExpenseCategory,
    required this.periodTransactions,
  });

  double get salesChange => previousSales == 0 ? 0 : (totalSales - previousSales) / previousSales;
  double get expenseChange => previousExpenses == 0 ? 0 : (totalExpenses - previousExpenses) / previousExpenses;

  String getInsight() {
    final saleUp = salesChange > 0.05;
    final saleDown = salesChange < -0.05;
    final expUp = expenseChange > 0.05;
    final expDown = expenseChange < -0.05;

    String periodStr = "";
    switch (period) {
      case AnalyticsPeriod.day: periodStr = "최근 며칠간"; break;
      case AnalyticsPeriod.week: periodStr = "이번 주"; break;
      case AnalyticsPeriod.month: periodStr = "이번 달"; break;
      case AnalyticsPeriod.year: periodStr = "올해"; break;
    }

    if (!saleUp && !saleDown && !expUp && !expDown) {
      return "$periodStr 운영 흐름이 매우 안정적입니다. 지금처럼 정갈하게 유지해 주세요.";
    }

    if (saleUp && expDown) {
      return "$periodStr 매출은 늘고 지출은 줄어 이상적인 성과를 거두고 있습니다! 훌륭해요.";
    }

    if (saleUp && expUp) {
      return "$periodStr 매출이 늘었지만 재료비 지출도 함께 증가했습니다. 단가 안정이 필요할 수 있습니다.";
    }

    if (saleDown && expDown) {
      return "$periodStr 지출을 잘 아꼈지만 매출이 다소 주춤하네요. 아뜰리에의 새 메뉴를 고민해볼 때일까요?";
    }

    if (saleDown && expUp) {
      return "$periodStr 지출이 늘고 매출이 줄어 주의가 필요합니다. 장부를 꼼꼼히 다시 살펴봐야겠어요.";
    }

    return "$periodStr 전반적으로 완만한 흐름을 보이고 있습니다. 꾸준함이 최고의 품질을 만듭니다.";
  }
}

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) => AnalyticsPeriod.day);

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final transactions = ref.watch(transactionProvider);
  final pantryItems = ref.watch(pantryProvider);
  final period = ref.watch(analyticsPeriodProvider);

  final now = DateTime.now();
  final Map<String, double> salesMap = {};
  final Map<String, double> expensesMap = {};
  final List<String> dates = [];

  // Determine date range and formatting based on period
  late DateTime startDate;
  late DateFormat labelFormat;
  late int steps;
  
  switch (period) {
    case AnalyticsPeriod.day:
      steps = 7;
      startDate = now.subtract(Duration(days: steps - 1));
      labelFormat = DateFormat('MM/dd');
      break;
    case AnalyticsPeriod.week:
      steps = 4;
      // Start from the beginning of the week 4 weeks ago
      final daysToSubtract = (now.weekday - 1) + (7 * (steps - 1));
      startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
      labelFormat = DateFormat('MM.dd');
      break;
    case AnalyticsPeriod.month:
      steps = 6;
      startDate = DateTime(now.year, now.month - steps + 1, 1);
      labelFormat = DateFormat('MMM');
      break;
    case AnalyticsPeriod.year:
      steps = 3;
      startDate = DateTime(now.year - steps + 1, 1, 1);
      labelFormat = DateFormat('yyyy');
      break;
  }

  // Initialize maps
  for (int i = 0; i < steps; i++) {
    DateTime date;
    String label;
    if (period == AnalyticsPeriod.day) {
      date = startDate.add(Duration(days: i));
      label = labelFormat.format(date);
    } else if (period == AnalyticsPeriod.week) {
      DateTime weekStart = startDate.add(Duration(days: i * 7));
      DateTime weekEnd = weekStart.add(const Duration(days: 6));
      label = "${DateFormat('MM.dd').format(weekStart)}~${DateFormat('dd').format(weekEnd)}";
    } else if (period == AnalyticsPeriod.month) {
      date = DateTime(startDate.year, startDate.month + i, 1);
      label = labelFormat.format(date);
    } else {
      date = DateTime(startDate.year + i, 1, 1);
      label = labelFormat.format(date);
    }
    dates.add(label);
    salesMap[label] = 0;
    expensesMap[label] = 0;
  }

  // Aggregate current period trends
  for (final tx in transactions) {
    String? label;
    if (period == AnalyticsPeriod.day) {
      label = labelFormat.format(tx.date);
    } else if (period == AnalyticsPeriod.week) {
      if (tx.date.isAfter(startDate) || tx.date.isAtSameMomentAs(startDate)) {
        final daysDiff = tx.date.difference(startDate).inDays;
        final weekIdx = (daysDiff / 7).floor();
        if (weekIdx < steps) {
          DateTime wStart = startDate.add(Duration(days: weekIdx * 7));
          DateTime wEnd = wStart.add(const Duration(days: 6));
          label = "${DateFormat('MM.dd').format(wStart)}~${DateFormat('dd').format(wEnd)}";
        }
      }
    } else if (period == AnalyticsPeriod.month) {
      label = labelFormat.format(tx.date);
    } else {
      label = labelFormat.format(tx.date);
    }

    if (label != null && salesMap.containsKey(label)) {
      if (tx.type == 'sale') {
        salesMap[label] = (salesMap[label] ?? 0) + tx.amount;
      } else {
        expensesMap[label] = (expensesMap[label] ?? 0) + tx.amount;
      }
    }
  }

  // Calculate totals and previous period totals for comparison
  late DateTime prevStartDate;
  late DateTime prevEndDate;
  
  if (period == AnalyticsPeriod.day) {
    prevEndDate = startDate;
    prevStartDate = startDate.subtract(const Duration(days: 7));
  } else if (period == AnalyticsPeriod.week) {
    prevEndDate = startDate;
    prevStartDate = startDate.subtract(const Duration(days: 28));
  } else if (period == AnalyticsPeriod.month) {
    prevEndDate = startDate;
    prevStartDate = DateTime(startDate.year, startDate.month - steps, 1);
  } else {
    prevEndDate = startDate;
    prevStartDate = DateTime(startDate.year - steps, 1, 1);
  }

  final totalSales = transactions
      .where((t) => t.type == 'sale' && t.date.isAfter(startDate))
      .fold(0.0, (sum, t) => sum + t.amount);
  final totalExpenses = transactions
      .where((t) => t.type == 'expense' && t.date.isAfter(startDate))
      .fold(0.0, (sum, t) => sum + t.amount);

  final previousSales = transactions
      .where((t) => t.type == 'sale' && t.date.isAfter(prevStartDate) && t.date.isBefore(prevEndDate))
      .fold(0.0, (sum, t) => sum + t.amount);
  final previousExpenses = transactions
      .where((t) => t.type == 'expense' && t.date.isAfter(prevStartDate) && t.date.isBefore(prevEndDate))
      .fold(0.0, (sum, t) => sum + t.amount);

  // Top Expense Category
  final Map<String, double> expenseByCategory = {};
  for (final tx in transactions.where((t) => t.type == 'expense' && t.date.isAfter(startDate))) {
    expenseByCategory[tx.category] = (expenseByCategory[tx.category] ?? 0) + tx.amount;
  }
  String? topCat;
  double maxExp = 0;
  expenseByCategory.forEach((cat, amt) {
    if (amt > maxExp) {
      maxExp = amt;
      topCat = cat;
    }
  });

  // Inventory Distribution
  final Map<String, int> categoryCounts = {};
  for (final item in pantryItems) {
    categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
  }

  final currentTxs = transactions.where((t) => t.date.isAfter(startDate)).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  return AnalyticsData(
    salesTrend: salesMap,
    expenseTrend: expensesMap,
    trendDates: dates,
    inventoryDistribution: categoryCounts,
    totalSales: totalSales,
    totalExpenses: totalExpenses,
    previousSales: previousSales,
    previousExpenses: previousExpenses,
    period: period,
    topExpenseCategory: topCat,
    periodTransactions: currentTxs,
  );
});
