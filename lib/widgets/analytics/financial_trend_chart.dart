import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/artisanal_theme.dart';
import '../../providers/analytics_provider.dart';

class FinancialTrendChart extends ConsumerWidget {
  const FinancialTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final salesMap = analytics.salesTrend;
    final expensesMap = analytics.expenseTrend;
    final dates = analytics.trendDates;
    
    final maxVal = _calculateMaxY(salesMap, expensesMap);

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => ArtisanalTheme.primary.withValues(alpha: 0.95),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  NumberFormat.compactCurrency(symbol: '₩', decimalDigits: 0).format(rod.toY),
                  ArtisanalTheme.hand(color: Colors.white, fontSize: 13),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < dates.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        dates[value.toInt()],
                        style: ArtisanalTheme.hand(fontSize: 10, color: Colors.black26),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compactCurrency(symbol: '₩', decimalDigits: 0).format(value),
                    style: ArtisanalTheme.hand(fontSize: 9, color: Colors.black26),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1), width: 1),
              left: BorderSide(color: Colors.black.withValues(alpha: 0.1), width: 1),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal > 0 ? maxVal / 5 : 10000,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.black.withValues(alpha: 0.04),
              strokeWidth: 1,
            ),
          ),
          barGroups: List.generate(dates.length, (i) {
            final date = dates[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: salesMap[date]!,
                  color: ArtisanalTheme.primary.withValues(alpha: 0.8),
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(1)),
                ),
                BarChartRodData(
                  toY: expensesMap[date]!,
                  color: ArtisanalTheme.redInk.withValues(alpha: 0.3),
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(1)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  double _calculateMaxY(Map<String, double> sales, Map<String, double> expenses) {
    double maxValue = 50000;
    for (final v in sales.values) {
      if (v > maxValue) maxValue = v;
    }
    for (final v in expenses.values) {
      if (v > maxValue) maxValue = v;
    }
    return maxValue * 1.3;
  }
}
