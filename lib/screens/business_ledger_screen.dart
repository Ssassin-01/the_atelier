import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/pantry_provider.dart';
import 'pantry_management_screen.dart';
import 'expense_history_screen.dart';
import 'business_analytics_screen.dart';
import '../services/pdf_service.dart';
import '../widgets/sales_slip_sheet.dart';
import '../widgets/low_stock_pannel.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/serrated_ledger_card.dart';

class BusinessLedgerScreen extends ConsumerWidget {
  const BusinessLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactions = ref.watch(transactionProvider);
    final pantryItems = ref.watch(pantryProvider);
    final txNotifier = ref.read(transactionProvider.notifier);

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: ArtisanalTheme.primary),
        title: Text(l10n.appTitle,
            style: ArtisanalTheme.lightTheme.textTheme.displayMedium
                ?.copyWith(fontSize: 24, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1583394838336-acd977730f8a?q=80&w=100'),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.businessOperations,
              style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: ArtisanalTheme.primary),
            ),
            const SizedBox(height: 16),
            LowStockPannel(items: pantryItems),
            const SizedBox(height: 24),
            Row(
              children: [
                QuickActionButton(
                    label: l10n.manageDatabase,
                    icon: Icons.storage,
                    color: const Color(0xFF8C6F1D),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryManagementScreen()))),
                const SizedBox(width: 8),
                QuickActionButton(
                    label: l10n.analytics,
                    icon: Icons.analytics_outlined,
                    color: const Color(0xFF5D4037),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessAnalyticsScreen()))),
                const SizedBox(width: 8),
                QuickActionButton(
                    label: l10n.addSale,
                    icon: Icons.add_shopping_cart,
                    color: ArtisanalTheme.primary,
                    onTap: () => _showSalesSlip(context)),
                const SizedBox(width: 8),
                QuickActionButton(
                    label: l10n.exportPdf,
                    icon: Icons.picture_as_pdf,
                    color: const Color(0xFF8C6F1D),
                    onTap: () => PdfService.generateFinancialReport(transactions, l10n.ingredientLedger)),
              ],
            ),
            const SizedBox(height: 40),
            SerratedLedgerCard(
              totalExpenses: txNotifier.getTotal('expense'),
              transactions: transactions,
              onHistoryTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseHistoryScreen())),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void _showSalesSlip(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const SalesSlipSheet(),
      ),
    );
  }
}
