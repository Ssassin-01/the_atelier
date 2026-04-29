import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/analytics_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../services/data_seed_service.dart';
import '../widgets/artisanal_card.dart';
import '../widgets/analytics/financial_trend_chart.dart';
import '../widgets/analytics/inventory_distribution_chart.dart';
import '../widgets/custom_clippers.dart';
import '../widgets/sales_slip_sheet.dart';
import '../widgets/masking_tape.dart';
import '../widgets/artisanal_barcode.dart';
import '../widgets/analytics/hourly_pattern_chart.dart';
import '../widgets/analytics/weekly_distribution_chart.dart';
import '../widgets/analytics/monthly_cost_analysis.dart';
import '../widgets/analytics/popular_items_list.dart';

class BusinessAnalyticsScreen extends ConsumerStatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  ConsumerState<BusinessAnalyticsScreen> createState() => _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends ConsumerState<BusinessAnalyticsScreen> {
  int _activeChartIndex = 0; // 0: Financial, 1: Inventory

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analytics = ref.watch(analyticsProvider);

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
            tooltip: l10n.seedTooltip,
            onPressed: () async {
              await DataSeedService.seedAllData(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.dataCurated, 
                      style: ArtisanalTheme.hand(color: Colors.white)),
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
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(ref, l10n),
              const SizedBox(height: 24),
              
              // 1. Action Buttons Row
              _buildTransactionActionButtons(context, l10n),
              
              const SizedBox(height: 32),
              
              // 2. Visual Insights (Financial Trends) - Moved Up
              _buildVisualAnalyticsSection(analytics, l10n),
              
              const SizedBox(height: 48),
              
              // 3. Integrated Business Journal Receipt (Detailed Ledger)
              _buildSummarySection(context, analytics, l10n),
              
              const SizedBox(height: 48),
              
              _buildInsightSection(analytics.getInsight()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualAnalyticsSection(AnalyticsData analytics, AppLocalizations l10n) {
    return ArtisanalCard(
      title: _activeChartIndex == 0 ? l10n.financialTrends : l10n.inventoryDistribution,
      rotation: 0.005,
      tapeLabel: l10n.analytics.toUpperCase(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartToggle(0, Icons.show_chart, l10n.trends),
              const SizedBox(width: 12),
              _buildChartToggle(1, Icons.pie_chart_outline, l10n.inventory),
            ],
          ),
          const SizedBox(height: 32),
          
          // Primary Trend Chart
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _activeChartIndex == 0
                ? const FinancialTrendChart(key: ValueKey('trend'))
                : Column(
                    key: const ValueKey('inventory'),
                    children: [
                      const InventoryDistributionChart(),
                      if (analytics.topExpenseCategory != null) ...[
                        const SizedBox(height: 16),
                        _buildTopExpenseBadge(l10n, analytics.topExpenseCategory!),
                      ],
                    ],
                  ),
          ),

          const SizedBox(height: 48),
          _dottedDivider(),
          const SizedBox(height: 40),

          // Period Specific Insights
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildPeriodSpecificInsight(analytics, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSpecificInsight(AnalyticsData data, AppLocalizations l10n) {
    switch (data.period) {
      case AnalyticsPeriod.day:
        return HourlyPatternChart(key: const ValueKey('daily-insight'), hourlySales: data.hourlySales);
      case AnalyticsPeriod.week:
        return WeeklyDistributionChart(key: const ValueKey('weekly-insight'), weekdaySales: data.weekdaySales);
      case AnalyticsPeriod.month:
        return Column(
          key: const ValueKey('monthly-insight'),
          children: [
            MonthlyCostAnalysis(fixedCosts: data.fixedCosts, variableCosts: data.variableCosts),
            const SizedBox(height: 32),
            PopularItemsList(items: data.topSellingItems),
          ],
        );
      case AnalyticsPeriod.year:
        return Column(
          key: const ValueKey('yearly-insight'),
          children: [
            Text(
              "올해의 베스트 어워즈",
              style: ArtisanalTheme.note(fontSize: 12, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            PopularItemsList(items: data.topSellingItems),
            const SizedBox(height: 32),
            Text(
              "연간 성장 리포트",
              style: ArtisanalTheme.note(fontSize: 12, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            const FinancialTrendChart(), // Reuse trend chart but it adapts to year
          ],
        );
    }
  }

  Widget _buildChartToggle(int index, IconData icon, String label) {
    final isSelected = _activeChartIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeChartIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : ArtisanalTheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: ArtisanalTheme.hand(
                fontSize: 12,
                color: isSelected ? Colors.white : ArtisanalTheme.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExpenseBadge(AppLocalizations l10n, String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ArtisanalTheme.redInk.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ArtisanalTheme.redInk.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 14, color: ArtisanalTheme.redInk),
          const SizedBox(width: 8),
          Text(
            "${l10n.topExpenseItem}: ",
            style: ArtisanalTheme.note(fontSize: 12, fontWeight: FontWeight.bold, color: ArtisanalTheme.redInk),
          ),
          Text(
            category,
            style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.redInk),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref, AppLocalizations l10n) {
    final currentPeriod = ref.watch(analyticsPeriodProvider);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ArtisanalTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: AnalyticsPeriod.values.map((p) {
          final isSelected = currentPeriod == p;
          String label;
          switch (p) {
            case AnalyticsPeriod.day: label = l10n.daily; break; // Ensure these exist in l10n
            case AnalyticsPeriod.week: label = l10n.weekly; break;
            case AnalyticsPeriod.month: label = l10n.monthly; break;
            case AnalyticsPeriod.year: label = l10n.yearly; break;
          }
          
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(analyticsPeriodProvider.notifier).state = p,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? ArtisanalTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    label.toUpperCase(),
                    style: ArtisanalTheme.hand(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : ArtisanalTheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightSection(String insight) {
    return Transform.rotate(
      angle: 0.02,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9E7), // Sticky note yellow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
            // A bit of paper edge effect
            borderRadius: BorderRadius.circular(2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   const Icon(Icons.edit_note, size: 18, color: Colors.brown),
                   const SizedBox(width: 8),
                   Text(
                     "ARTISAN'S LOG",
                     style: ArtisanalTheme.note(
                       fontSize: 12,
                       fontWeight: FontWeight.bold,
                       color: Colors.brown.withValues(alpha: 0.6),
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                insight,
                style: ArtisanalTheme.hand(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.brown.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodHighlight(AnalyticsData data, AppLocalizations l10n) {
    String highlightText = "";
    IconData icon = Icons.auto_awesome;
    
    switch (data.period) {
      case AnalyticsPeriod.day:
        final hour = data.busiestHour;
        highlightText = hour != null 
          ? "오늘 오후 ${hour > 12 ? hour - 12 : hour}시경이 가장 활기찼습니다."
          : "차분한 하루였습니다. 연구에 집중하기 좋았네요.";
        icon = Icons.access_time;
        break;
      case AnalyticsPeriod.week:
        final dayNum = data.busiestDay;
        final days = ['월', '화', '수', '목', '금', '토', '일'];
        highlightText = dayNum != null
          ? "${days[dayNum - 1]}요일에 손님들이 가장 많이 찾아주셨어요."
          : "평화로운 일주일이었습니다.";
        icon = Icons.calendar_view_week;
        break;
      case AnalyticsPeriod.month:
        final topItem = data.topItemName;
        highlightText = topItem != null
          ? "이번 달의 주인공은 '$topItem'이었습니다."
          : "이달은 새로운 시도가 많았던 시기였네요.";
        icon = Icons.star_border;
        break;
      case AnalyticsPeriod.year:
        final growth = data.salesChange;
        highlightText = growth > 0
          ? "작년보다 ${(growth * 100).toStringAsFixed(1)}% 성장했습니다. 장인의 땀방울이 맺힌 결과네요."
          : "내실을 다지는 한 해였습니다. 내년의 도약이 기대됩니다.";
        icon = Icons.trending_up;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArtisanalTheme.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ArtisanalTheme.primary.withValues(alpha: 0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              highlightText,
              style: ArtisanalTheme.hand(
                fontSize: 14,
                color: ArtisanalTheme.ink.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, AnalyticsData data, AppLocalizations l10n) {
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol, decimalDigits: 0);
    
    String overviewLabel;
    switch (data.period) {
      case AnalyticsPeriod.day: overviewLabel = l10n.dailyOverview; break;
      case AnalyticsPeriod.week: overviewLabel = l10n.weeklyOverview; break;
      case AnalyticsPeriod.month: overviewLabel = l10n.monthlyOverview; break;
      case AnalyticsPeriod.year: overviewLabel = l10n.yearlyOverview; break;
    }

    final profit = data.totalSales - data.totalExpenses;
    final isProfitPositive = profit >= 0;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: data.period == AnalyticsPeriod.month || data.period == AnalyticsPeriod.year
                  ? null // No serrated edge for magazine/archive
                  : SerratedClipper(toothWidth: 10, toothHeight: 5),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 56, 32, 48),
                  decoration: BoxDecoration(
                    color: data.period == AnalyticsPeriod.year ? const Color(0xFFFAF9F6) : Colors.white,
                    borderRadius: data.period == AnalyticsPeriod.month || data.period == AnalyticsPeriod.year
                      ? BorderRadius.circular(4)
                      : null,
                    border: data.period == AnalyticsPeriod.year 
                      ? Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.1), width: 1)
                      : null,
                    image: DecorationImage(
                      image: const NetworkImage('https://www.transparenttextures.com/patterns/paper-fibers.png'),
                      repeat: ImageRepeat.repeat,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.03),
                        BlendMode.dstATop,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptHeader(context, l10n.businessJournalTitle, isProfitPositive),
                      const SizedBox(height: 4),
                      Text(
                        "${overviewLabel.toUpperCase()} (${DateFormat('MMM').format(DateTime.now())})",
                        style: ArtisanalTheme.receipt(
                          fontSize: 10,
                          color: ArtisanalTheme.ink.withValues(alpha: 0.2),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // 1. REFINED BREAKDOWN SECTION (Summary) - NO ICONS
                      _buildCleanReceiptRow(
                        context,
                        l10n.totalRevenue,
                        data.totalSales,
                        data.salesChange,
                        ArtisanalTheme.primary,
                        null, // Removed icon
                      ),
                      const SizedBox(height: 20),
                      _buildCleanReceiptRow(
                        context,
                        l10n.totalExpensesLabel,
                        data.totalExpenses,
                        data.expenseChange,
                        ArtisanalTheme.redInk,
                        null, // Removed icon
                      ),
                      
                      const SizedBox(height: 32),
                      _dottedDivider(thick: true),
                      const SizedBox(height: 32),

                      // 2. GRAND TOTAL SECTION (Net Profit)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "최종 정산",
                                  style: ArtisanalTheme.receipt(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: ArtisanalTheme.ink.withValues(alpha: 0.8),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  l10n.netProfitLabel.toUpperCase(),
                                  style: ArtisanalTheme.receipt(
                                    fontSize: 10,
                                    color: ArtisanalTheme.ink.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currencyFormat.format(profit),
                            style: ArtisanalTheme.receipt(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: isProfitPositive ? ArtisanalTheme.greenInk : Colors.red.shade700,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      _dottedDivider(thick: true),

                      // PERIOD SPECIFIC CONTENT INSIDE RECEIPT
                      const SizedBox(height: 32),
                      _buildReceiptDetailContent(data, currencyFormat, l10n),

                      const SizedBox(height: 32),
                      _dottedDivider(thick: true),

                      // PERIOD HIGHLIGHTS (Handwritten style)
                      const SizedBox(height: 32),
                      _buildPeriodHighlight(data, l10n),

                      const SizedBox(height: 40),
                      const ArtisanalBarcode(code: 'BUSINESS-SUMMARY-2024'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Masking Tape
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: MaskingTape(
                    label: l10n.verified,
                    width: 100,
                    rotation: -0.03,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetailContent(AnalyticsData data, NumberFormat format, AppLocalizations l10n) {
    if (data.period == AnalyticsPeriod.day || data.period == AnalyticsPeriod.week) {
      // Integrated Ledger for Daily/Weekly
      final txs = data.periodTransactions.whereType<BusinessTransaction>().take(8).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "상세 장부 내역",
                style: ArtisanalTheme.receipt(fontSize: 10, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink.withValues(alpha: 0.3)),
              ),
              InkWell(
                onTap: () => _showFullLedger(context, data, format, l10n),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ArtisanalTheme.ink.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "상세 내역 전체 보기",
                        style: ArtisanalTheme.receipt(
                          fontSize: 10, 
                          color: ArtisanalTheme.ink.withValues(alpha: 0.6), 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 8, color: ArtisanalTheme.ink.withValues(alpha: 0.4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (txs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text("기록된 내역이 없습니다.", 
                  style: ArtisanalTheme.receipt(fontSize: 13, color: ArtisanalTheme.ink.withValues(alpha: 0.2))),
              ),
            )
          else
            ...txs.map((tx) => InkWell(
              onTap: () => _showSalesSlip(context, type: tx.type, initialTransaction: tx),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.description, 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis, 
                            style: ArtisanalTheme.receipt(fontSize: 13, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink)),
                          Text(DateFormat('HH:mm').format(tx.date), 
                            style: ArtisanalTheme.receipt(fontSize: 9, color: ArtisanalTheme.ink.withValues(alpha: 0.3))),
                        ],
                      ),
                    ),
                    Text(
                      "${tx.type == 'sale' ? '+' : '-'}${format.format(tx.amount)}", 
                      style: ArtisanalTheme.receipt(
                        fontSize: 14, 
                        color: tx.type == 'sale' ? ArtisanalTheme.greenInk : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          if (data.periodTransactions.length > 8) ...[
             const SizedBox(height: 12),
             Center(
               child: InkWell(
                 onTap: () => _showFullLedger(context, data, format, l10n),
                 child: Padding(
                   padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                   child: Text(
                     "외 ${data.periodTransactions.length - 8}개의 내역이 더 있습니다. (전체 보기)",
                     style: ArtisanalTheme.receipt(
                       fontSize: 9, 
                       color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                       fontWeight: FontWeight.bold,
                       decoration: TextDecoration.underline,
                     ),
                   ),
                 ),
               ),
             ),
          ],
        ],
      );
    } else {
      // Performance Summary for Monthly/Yearly
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "실적 요약 보고",
            style: ArtisanalTheme.receipt(fontSize: 10, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow("가장 많이 팔린 품목", data.topItemName ?? "없음"),
          const SizedBox(height: 8),
          _buildSummaryRow("주요 지출 카테고리", data.topExpenseCategory ?? "없음"),
          if (data.period == AnalyticsPeriod.month) ...[
            const SizedBox(height: 8),
            _buildSummaryRow("고정비 비중", "${(data.fixedCostRatio * 100).toStringAsFixed(1)}%"),
          ],
        ],
      );
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(), style: ArtisanalTheme.receipt(fontSize: 11, color: ArtisanalTheme.ink.withValues(alpha: 0.5))),
        Text(value, style: ArtisanalTheme.receipt(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildReceiptHeader(BuildContext context, String title, bool isProfitPositive) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ArtisanalTheme.lightTheme.textTheme.displaySmall?.copyWith(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: -10,
          right: -10,
          child: Transform.rotate(
            angle: -0.15,
            child: Text(
              (isProfitPositive ? l10n.profitVerified : l10n.deficitNoted).toUpperCase(),
              style: ArtisanalTheme.receipt(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: (isProfitPositive ? ArtisanalTheme.greenInk : ArtisanalTheme.redInk).withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dottedDivider({bool thick = false}) {
    return Row(
      children: List.generate(
          thick ? 60 : 40,
          (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: thick ? 2 : 1,
                  color: index % 2 == 0 
                    ? ArtisanalTheme.ink.withValues(alpha: thick ? 0.5 : 0.3) 
                    : Colors.transparent,
                ),
              )),
    );
  }

  Widget _buildCleanReceiptRow(BuildContext context, String label, double amount, double change, Color color, IconData? icon) {
    final currencyFormat = NumberFormat.currency(symbol: AppLocalizations.of(context).currencySymbol, decimalDigits: 0);
    final isIncrease = change >= 0;
    final isRevenue = label == AppLocalizations.of(context).totalRevenue; 
    
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: color.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: ArtisanalTheme.receipt(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                ),
              ),
              if (change != 0)
                Text(
                  "${(change.abs() * 100).toStringAsFixed(0)}% ${isIncrease ? '↑' : '↓'}",
                  style: ArtisanalTheme.receipt(
                    fontSize: 11,
                    color: isRevenue 
                      ? (isIncrease ? ArtisanalTheme.greenInk : Colors.red.shade700)
                      : (isIncrease ? Colors.red.shade700 : ArtisanalTheme.greenInk),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        Text(
          "${isRevenue ? '+' : '-'}${currencyFormat.format(amount)}",
          style: ArtisanalTheme.receipt(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isRevenue ? ArtisanalTheme.greenInk : Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionActionButtons(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            label: '매출 기록',
            icon: Icons.add_circle,
            color: ArtisanalTheme.greenInk,
            onPressed: () => _showSalesSlip(context, type: 'sale'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            label: '지출 기록',
            icon: Icons.remove_circle,
            color: ArtisanalTheme.redInk,
            onPressed: () => _showSalesSlip(context, type: 'expense'), 
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: ArtisanalTheme.hand(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullLedger(BuildContext context, AnalyticsData data, NumberFormat format, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.none, // Allow overflow for the clip
      builder: (context) => _FullLedgerSheet(initialData: data, format: format),
    );
  }

  Widget _buildLedgerStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ArtisanalTheme.receipt(fontSize: 10, color: ArtisanalTheme.ink.withValues(alpha: 0.4))),
          const SizedBox(height: 4),
          Text(value, style: ArtisanalTheme.receipt(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showSalesSlip(BuildContext context, {String type = 'sale', BusinessTransaction? initialTransaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SalesSlipSheet(type: type, initialTransaction: initialTransaction),
      ),
    );
  }
}

class _FullLedgerSheet extends ConsumerStatefulWidget {
  final AnalyticsData initialData;
  final NumberFormat format;

  const _FullLedgerSheet({required this.initialData, required this.format});

  @override
  ConsumerState<_FullLedgerSheet> createState() => _FullLedgerSheetState();
}

class _FullLedgerSheetState extends ConsumerState<_FullLedgerSheet> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final l10n = AppLocalizations.of(context);
    
    // Filter transactions
    final filteredTxs = transactions.where((tx) {
      return tx.date.year == _selectedDate.year && 
             tx.date.month == _selectedDate.month &&
             (widget.initialData.period == AnalyticsPeriod.day ? tx.date.day == _selectedDate.day : true);
    }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

    final totalSales = filteredTxs.where((tx) => tx.type == 'sale').fold(0.0, (sum, item) => sum + item.amount);
    final totalExpenses = filteredTxs.where((tx) => tx.type == 'expense').fold(0.0, (sum, item) => sum + item.amount);
    final balance = totalSales - totalExpenses;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      color: Colors.transparent, // Transparent root container
      child: Stack(
        clipBehavior: Clip.none, // Allow overflow for the floating clip
        children: [
          // 1. The main "Paper" Container with padding to accommodate the clip
          Padding(
            padding: const EdgeInsets.only(top: 15), // Offset for the clip
            child: Container(
              decoration: const BoxDecoration(
                color: ArtisanalTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Dot Grid Background (Needs to be inside the paper)
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DotGridPainter(),
                          ),
                        ),
                        Column(
                          children: [
                            // Header
                            _buildFolderTabHeader(context),
                            _buildSummarySection(context, totalSales, totalExpenses, balance),
                            _buildFilterBar(context, filteredTxs.length),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Colors.black12),
                            Expanded(child: _buildLedgerList(context, filteredTxs, widget.format)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Metal Clip
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 74,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFB0BEC5),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Close Button - Floating independently to save space
          Positioned(
            top: 25,
            right: 12,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.close_rounded, color: ArtisanalTheme.ink, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // Refactored helper methods for cleaner build
  Widget _buildSummarySection(BuildContext context, double totalSales, double totalExpenses, double balance) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), // Zero top padding
      child: Row(
        children: [
          Expanded(child: _buildSummaryIndexCard(l10n.revenue, totalSales, ArtisanalTheme.greenInk)),
          const SizedBox(width: 12),
          Expanded(child: _buildSummaryIndexCard(l10n.expense, totalExpenses, ArtisanalTheme.redInk)),
          const SizedBox(width: 12),
          Expanded(child: _buildSummaryIndexCard(l10n.balance, balance, balance >= 0 ? ArtisanalTheme.primary : ArtisanalTheme.redInk)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, int count) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildDateStamp(context),
          const Spacer(),
          Text(
            "$count ${l10n.entriesRecordedLabel}",
            style: ArtisanalTheme.receipt(fontSize: 10, color: ArtisanalTheme.ink.withValues(alpha: 0.3), letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerList(BuildContext context, List<BusinessTransaction> txs, NumberFormat format) {
    if (txs.isEmpty) return _buildEmptyState(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      itemCount: txs.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: ArtisanalTheme.ink.withValues(alpha: 0.04)),
      itemBuilder: (context, index) => _buildProfessionalEntry(context, txs[index], format),
    );
  }

  Widget _buildFolderTabHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 12), // Added small bottom padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.masterLedgerArchive,
            style: ArtisanalTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              color: ArtisanalTheme.ink,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "MANAGEMENT ARCHIVE",
                  style: ArtisanalTheme.receipt(fontSize: 9, color: ArtisanalTheme.ink.withValues(alpha: 0.3), letterSpacing: 1.5),
                ),
              ),
              Container(width: 40, height: 1, color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
            ],
          ),
          const SizedBox(height: 6), // Further reduced gap
          Text(
            l10n.tapToModifyOrDelete,
            style: ArtisanalTheme.receipt(fontSize: 10, color: ArtisanalTheme.ink.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryIndexCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ArtisanalTheme.receipt(fontSize: 9, color: ArtisanalTheme.ink.withValues(alpha: 0.4))),
          const SizedBox(height: 4),
          Text(
            widget.format.format(value),
            style: ArtisanalTheme.receipt(fontSize: 12, fontWeight: FontWeight.w900, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDateStamp(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ArtisanalTheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 16, color: ArtisanalTheme.primary),
            const SizedBox(width: 12),
            Text(
              DateFormat('yyyy. MM. dd').format(_selectedDate),
              style: ArtisanalTheme.receipt(fontSize: 13, fontWeight: FontWeight.bold, color: ArtisanalTheme.primary),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: ArtisanalTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalEntry(BuildContext context, BusinessTransaction tx, NumberFormat format) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SalesSlipSheet(type: tx.type, initialTransaction: tx),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                DateFormat('HH:mm').format(tx.date),
                style: ArtisanalTheme.receipt(fontSize: 11, color: ArtisanalTheme.ink.withValues(alpha: 0.3)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: tx.type == 'sale' ? ArtisanalTheme.greenInk : ArtisanalTheme.redInk,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    style: ArtisanalTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    tx.category.toUpperCase(),
                    style: ArtisanalTheme.receipt(fontSize: 8, color: ArtisanalTheme.ink.withValues(alpha: 0.3), letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            Text(
              "${tx.type == 'sale' ? '+' : '-'}${format.format(tx.amount)}",
              style: ArtisanalTheme.receipt(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: tx.type == 'sale' ? ArtisanalTheme.greenInk : ArtisanalTheme.redInk,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.edit_note_rounded, size: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.15)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: ArtisanalTheme.ink.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          Text(
            l10n.noEntriesOnSelectedDate,
            style: ArtisanalTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: ArtisanalTheme.ink.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ArtisanalTheme.ink.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    const double spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
