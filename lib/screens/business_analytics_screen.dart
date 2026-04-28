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
              
              // New Action Buttons Row
              _buildTransactionActionButtons(context, l10n),
              
              const SizedBox(height: 32),
              
              // 1. Hero Summary (Business Journal)
              _buildSummarySection(context, analytics, l10n),
              
              const SizedBox(height: 48),
              
              // 2. Visual Insights (Consolidated Charts)
              _buildVisualAnalyticsSection(analytics, l10n),
              
              const SizedBox(height: 48),
              
              // 3. Bottom Log
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
        ],
      ),
    );
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
                clipper: SerratedClipper(toothWidth: 10, toothHeight: 5),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 56, 32, 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        style: ArtisanalTheme.note(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "GRAND TOTAL",
                                style: ArtisanalTheme.note(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ArtisanalTheme.ink.withValues(alpha: 0.8),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                l10n.netProfitLabel.toUpperCase(),
                                style: ArtisanalTheme.note(
                                  fontSize: 10,
                                  color: ArtisanalTheme.ink.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currencyFormat.format(profit),
                            style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: isProfitPositive ? Colors.green.shade700 : ArtisanalTheme.redInk,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      _dottedDivider(thick: true),

                      // DETAILED TRANSACTIONS SECTION
                      if (data.period == AnalyticsPeriod.day || data.period == AnalyticsPeriod.week) ...[
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            const Icon(Icons.list_alt, size: 14, color: ArtisanalTheme.ink),
                            const SizedBox(width: 8),
                            Text(
                              l10n.recentPurchases.toUpperCase(),
                              style: ArtisanalTheme.note(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ArtisanalTheme.ink.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _dottedDivider(),
                        const SizedBox(height: 24),
                        ...data.periodTransactions.whereType<BusinessTransaction>().map((tx) => _buildTransactionEntryVisual(context, tx, currencyFormat, l10n)),
                      ],
                      
                      const SizedBox(height: 48),
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

  Widget _buildReceiptHeader(BuildContext context, String title, bool isProfitPositive) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Text(
              title,
              style: ArtisanalTheme.lightTheme.textTheme.displaySmall?.copyWith(
                fontSize: 18,
                fontStyle: FontStyle.italic,
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
              style: ArtisanalTheme.hand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: (isProfitPositive ? ArtisanalTheme.primary : ArtisanalTheme.redInk).withValues(alpha: 0.4),
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
                style: ArtisanalTheme.note(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                ),
              ),
              if (change != 0)
                Text(
                  "${(change.abs() * 100).toStringAsFixed(0)}% ${isIncrease ? '↑' : '↓'}",
                  style: ArtisanalTheme.hand(
                    fontSize: 11,
                    color: isIncrease ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        Text(
          "${isRevenue ? '+' : '-'}${currencyFormat.format(amount)}",
          style: ArtisanalTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isRevenue ? Colors.green.shade700 : Colors.red.shade700,
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
            color: ArtisanalTheme.primary,
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

  Widget _buildTransactionEntryVisual(BuildContext context, BusinessTransaction tx, NumberFormat format, AppLocalizations l10n) {
    final isSale = tx.type == 'sale';
    return InkWell(
      onTap: () => _showTransactionOptions(context, tx),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtisanalTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM HH:mm').format(tx.date),
                    style: ArtisanalTheme.note(fontSize: 11, color: ArtisanalTheme.ink.withValues(alpha: 0.3)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "${isSale ? '+' : '-'}${format.format(tx.amount)}",
              style: ArtisanalTheme.hand(
                fontSize: 18,
                color: isSale ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionOptions(BuildContext context, BusinessTransaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tx.description,
              style: ArtisanalTheme.lightTheme.textTheme.displaySmall?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: ArtisanalTheme.primary),
              title: Text('수정하기', style: ArtisanalTheme.hand()),
              onTap: () {
                Navigator.pop(context);
                // Future: Show edit form
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: ArtisanalTheme.redInk),
              title: Text('삭제하기', style: ArtisanalTheme.hand(color: ArtisanalTheme.redInk)),
              onTap: () {
                ref.read(transactionProvider.notifier).deleteTransaction(tx.id);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSalesSlip(BuildContext context, {String type = 'sale'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SalesSlipSheet(type: type),
      ),
    );
  }
}
