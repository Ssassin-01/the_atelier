import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/artisanal_theme.dart';
import '../../providers/analytics_provider.dart';
import '../../l10n/app_localizations.dart';

class FinancialTrendChart extends ConsumerWidget {
  const FinancialTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final salesMap = analytics.salesTrend;
    final expensesMap = analytics.expenseTrend;
    final dates = analytics.trendDates;
    
    final maxVal = _calculateMaxY(salesMap, expensesMap);
    final l10n = AppLocalizations.of(context);
    final double cleanInterval = (maxVal > 0) ? (((maxVal / 4) / 50000).ceil() * 50000).toDouble() : 50000.0;
    
    return Column(
      children: [
        // Unit Indicator (Moved to the left above Y-axis)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "(단위: 만원)",
              style: ArtisanalTheme.receipt(
                fontSize: 9,
                color: ArtisanalTheme.ink.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => ArtisanalTheme.primary.withValues(alpha: 0.9),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isSales = spot.barIndex == 0;
                      return LineTooltipItem(
                        "${isSales ? l10n.revenue : l10n.expense}\n${NumberFormat.simpleCurrency(locale: 'ko_KR', decimalDigits: 0).format(spot.y)}",
                        ArtisanalTheme.hand(color: Colors.white, fontSize: 12),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: cleanInterval, 
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: ArtisanalTheme.ink.withValues(alpha: 0.05), // Subtle ink line
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: ArtisanalTheme.ink.withValues(alpha: 0.05), // Subtle ink line
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1, 
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < dates.length) {
                        String label = dates[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: ArtisanalTheme.receipt(
                              fontSize: 9,
                              color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                            ),
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
                    interval: cleanInterval, 
                    getTitlesWidget: (value, meta) {
                      // Format to "Man-won" (10,000 KRW)
                      final manWon = (value / 10000).toInt();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          "$manWon",
                          style: ArtisanalTheme.receipt(fontSize: 9, color: ArtisanalTheme.ink.withValues(alpha: 0.3)),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.05), width: 1),
              ),
              minX: 0,
              maxX: (dates.length - 1).toDouble(),
              minY: 0,
              maxY: ((maxVal / cleanInterval).ceil() * cleanInterval).toDouble(), // Snap maxY to interval
              lineBarsData: [
                // Revenue Line (Hand-drawn feel)
                LineChartBarData(
                  spots: List.generate(dates.length, (i) => FlSpot(i.toDouble(), salesMap[dates[i]] ?? 0)),
                  isCurved: true,
                  curveSmoothness: 0.4,
                  color: ArtisanalTheme.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  shadow: Shadow(
                    color: ArtisanalTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: ArtisanalTheme.primary,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: ArtisanalTheme.primary.withValues(alpha: 0.03),
                  ),
                ),
                // Expense Line (Dashed Hand-drawn feel)
                LineChartBarData(
                  spots: List.generate(dates.length, (i) => FlSpot(i.toDouble(), expensesMap[dates[i]] ?? 0)),
                  isCurved: true,
                  curveSmoothness: 0.4,
                  color: ArtisanalTheme.redInk.withValues(alpha: 0.7),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dashArray: [8, 4], 
                  shadow: Shadow(
                    color: ArtisanalTheme.redInk.withValues(alpha: 0.1),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: ArtisanalTheme.redInk.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(l10n.totalRevenue, ArtisanalTheme.primary),
            const SizedBox(width: 24),
            _buildLegendItem(l10n.operatingExpenses, ArtisanalTheme.redInk.withValues(alpha: 0.6), isDashed: true),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: ArtisanalTheme.receipt(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: ArtisanalTheme.ink.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  double _calculateMaxY(Map<String, double> sales, Map<String, double> expenses) {
    double maxValue = 100000;
    for (final v in sales.values) {
      if (v > maxValue) maxValue = v;
    }
    for (final v in expenses.values) {
      if (v > maxValue) maxValue = v;
    }
    
    // Round up to nearest 50,000 for clean intervals
    double result = maxValue * 1.2;
    return (result / 50000).ceil() * 50000;
  }
}
