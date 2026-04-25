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
import '../widgets/analytics/handwritten_stat.dart';

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
            tooltip: 'Seed Test Data',
            onPressed: () async {
              await DataSeedService.seedAllData(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Artisanal data curated successfully!', 
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArtisanalCard(
                title: l10n.recentPurchases,
                rotation: -0.015,
                tapeLabel: 'TRENDS',
                child: const FinancialTrendChart(),
              ),
              const SizedBox(height: 48),
              ArtisanalCard(
                title: l10n.inventoryDistribution,
                rotation: 0.012,
                tapeLabel: 'INVENTORY',
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

  Widget _buildSummarySection(AnalyticsData data, AppLocalizations l10n) {
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
        HandwrittenStat(
          label: l10n.totalMonthlySpend,
          value: currencyFormat.format(data.totalMonthlyExpenses),
          color: ArtisanalTheme.redInk,
        ),
        const SizedBox(height: 32),
        HandwrittenStat(
          label: l10n.ingredientLedger,
          value: currencyFormat.format(data.totalMonthlySales),
          color: ArtisanalTheme.primary,
        ),
      ],
    );
  }
}
