import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/pantry_provider.dart';
import '../models/transaction.dart';
import '../models/pantry_item.dart';
import '../services/data_seed_service.dart';
import '../widgets/masking_tape.dart';

class BusinessAnalyticsScreen extends ConsumerStatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  ConsumerState<BusinessAnalyticsScreen> createState() => _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends ConsumerState<BusinessAnalyticsScreen> {
  int touchedIndex = -1;
  int barTouchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final transactions = ref.watch(transactionProvider);
    final pantryItems = ref.watch(pantryProvider);

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ArtisanalTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.businessAnalytics,
            style: ArtisanalTheme.lightTheme.textTheme.displayMedium
                ?.copyWith(fontSize: 22, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: ArtisanalTheme.primary, size: 20),
            tooltip: 'Seed Test Data',
            onPressed: () async {
              await DataSeedService.seedAllData(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Artisanal data curated successfully!', style: ArtisanalTheme.hand(color: Colors.white)),
                    backgroundColor: ArtisanalTheme.primary,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage('https://www.transparenttextures.com/patterns/paper-fibers.png'),
            repeat: ImageRepeat.repeat,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.05),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildArtisanalCard(
                title: l10n.recentPurchases,
                child: _buildFinancialTrendChart(transactions),
                rotation: -0.015,
                tapeLabel: 'TRENDS',
              ),
              const SizedBox(height: 48),
              _buildArtisanalCard(
                title: l10n.inventoryDistribution,
                child: _buildInventoryPieChart(pantryItems, l10n),
                rotation: 0.012,
                tapeLabel: 'INVENTORY',
              ),
              const SizedBox(height: 48),
              _buildSummarySection(transactions, pantryItems, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtisanalCard({
    required String title,
    required Widget child,
    double rotation = 0,
    String? tapeLabel,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFCF7), // Light cream paper
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(4, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 2,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: ArtisanalTheme.hand(
                    fontSize: 14,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: ArtisanalTheme.primary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 1,
                  width: 30,
                  color: ArtisanalTheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
          Positioned(
            top: -15,
            right: 30,
            child: MaskingTape(
              width: 90,
              label: tapeLabel,
              rotation: 0.08,
              color: const Color(0xFFEEE7D1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTrendChart(List<BusinessTransaction> transactions) {
    final now = DateTime.now();
    final Map<String, double> salesMap = {};
    final Map<String, double> expensesMap = {};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('MM/dd').format(date);
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

    final dates = salesMap.keys.toList();
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
    for (final v in sales.values) { if (v > maxValue) maxValue = v; }
    for (final v in expenses.values) { if (v > maxValue) maxValue = v; }
    return maxValue * 1.3;
  }

  Widget _buildInventoryPieChart(List<PantryItem> items, AppLocalizations l10n) {
    final Map<String, int> categoryCounts = {};
    for (final item in items) {
      categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
    }

    final categories = categoryCounts.keys.toList();
    final colors = [
      ArtisanalTheme.primary.withValues(alpha: 0.7),
      const Color(0xFFD4C8A1),
      ArtisanalTheme.redInk.withValues(alpha: 0.5),
      const Color(0xFFC4B69C),
      const Color(0xFFAFA590),
      Colors.grey.withValues(alpha: 0.3),
    ];

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 35,
              sections: List.generate(categories.length, (i) {
                final category = categories[i];
                final count = categoryCounts[category]!;

                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: count.toDouble(),
                  title: '',
                  radius: 40,
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(categories.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      categories[i],
                      style: ArtisanalTheme.hand(fontSize: 12, color: Colors.black45),
                    ),
                    const Spacer(),
                    Text(
                      '${categoryCounts[categories[i]]}',
                      style: ArtisanalTheme.hand(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(List<BusinessTransaction> txs, List<PantryItem> items, AppLocalizations l10n) {
    final totalSales = txs.where((t) => t.type == 'sale').fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = txs.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_note, size: 20, color: ArtisanalTheme.primary),
            const SizedBox(width: 8),
            Text(
              'MONTHLY OVERVIEW',
              style: ArtisanalTheme.hand(
                fontSize: 12,
                letterSpacing: 2,
                color: ArtisanalTheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildHandwrittenStat(l10n.totalMonthlySpend, currencyFormat.format(totalExpenses), ArtisanalTheme.redInk),
        const SizedBox(height: 32),
        _buildHandwrittenStat(l10n.ingredientLedger, currencyFormat.format(totalSales), ArtisanalTheme.primary),
      ],
    );
  }

  Widget _buildHandwrittenStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ArtisanalTheme.hand(fontSize: 11, color: Colors.black26, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: ArtisanalTheme.hand(
                fontSize: 36,
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
              ).copyWith(letterSpacing: -1.5),
            ),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 2,
              width: 30,
              color: color.withValues(alpha: 0.15),
            ),
          ],
        ),
      ],
    );
  }
}
