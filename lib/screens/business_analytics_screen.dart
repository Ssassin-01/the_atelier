import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/analytics_provider.dart';
import '../services/data_seed_service.dart';
import '../widgets/artisanal_card.dart';
import '../widgets/analytics/financial_trend_chart.dart';
import '../widgets/analytics/inventory_distribution_chart.dart';
import '../widgets/custom_clippers.dart';

class BusinessAnalyticsScreen extends ConsumerStatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  ConsumerState<BusinessAnalyticsScreen> createState() => _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends ConsumerState<BusinessAnalyticsScreen> {
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
              _buildInsightSection(analytics.getInsight()),
              const SizedBox(height: 32),
              ArtisanalCard(
                title: l10n.recentPurchases,
                rotation: -0.015,
                tapeLabel: l10n.trends.toUpperCase(),
                child: const FinancialTrendChart(),
              ),
              const SizedBox(height: 48),
              ArtisanalCard(
                title: l10n.inventoryDistribution,
                rotation: 0.012,
                tapeLabel: l10n.inventory.toUpperCase(),
                child: const InventoryDistributionChart(),
              ),
              const SizedBox(height: 48),
              _buildSummarySection(analytics, l10n),
            ],
          ),
        ),
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

  Widget _buildSummarySection(AnalyticsData data, AppLocalizations l10n) {
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
      child: ClipPath(
        clipper: SerratedClipper(toothWidth: 10, toothHeight: 5),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 48),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFCF7), // Exact match with ArtisanalCard cream
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(4, 6), // Matching ArtisanalCard shadow direction
              ),
            ],
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
              Text(
                l10n.businessJournalTitle.toUpperCase(),
                style: ArtisanalTheme.hand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                overviewLabel.toUpperCase(),
                style: ArtisanalTheme.hand(
                  fontSize: 12,
                  color: ArtisanalTheme.secondary.withValues(alpha: 0.4), // Warmer than pure grey
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: ArtisanalTheme.primary.withValues(alpha: 0.1), thickness: 1, height: 1),
              ),
              
              _buildReceiptRow(
                l10n.ingredientLedger,
                "+${currencyFormat.format(data.totalSales)}",
                data.salesChange,
                ArtisanalTheme.primary,
              ),
              const SizedBox(height: 16),
              _buildReceiptRow(
                l10n.totalExpensesLabel,
                "-${currencyFormat.format(data.totalExpenses)}",
                data.expenseChange,
                ArtisanalTheme.redInk,
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Divider(color: ArtisanalTheme.primary.withValues(alpha: 0.1), thickness: 1, height: 1),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.netProfitLabel.toUpperCase(),
                    style: ArtisanalTheme.hand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${isProfitPositive ? '+' : ''}${currencyFormat.format(profit)}",
                    style: ArtisanalTheme.hand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isProfitPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Authentication Stamp
              Transform.rotate(
                angle: -0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (isProfitPositive ? ArtisanalTheme.primary : ArtisanalTheme.redInk).withValues(alpha: 0.4),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isProfitPositive ? l10n.profitVerified : l10n.deficitNoted,
                    style: ArtisanalTheme.hand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (isProfitPositive ? ArtisanalTheme.primary : ArtisanalTheme.redInk).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, double change, Color color) {
    final isPositive = change >= 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: ArtisanalTheme.note(fontSize: 11, color: ArtisanalTheme.ink.withValues(alpha: 0.5))),
            const SizedBox(height: 2),
            if (change != 0)
              Text(
                "${(change.abs() * 100).toStringAsFixed(0)}% ${isPositive ? '↑' : '↓'}",
                style: ArtisanalTheme.hand(
                  fontSize: 12,
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        Text(
          value,
          style: ArtisanalTheme.hand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
