import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_clippers.dart';
import '../widgets/polaroid_card.dart';
import '../providers/transaction_provider.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';
import 'pantry_management_screen.dart';
import 'expense_history_screen.dart';
import '../widgets/sales_slip_sheet.dart';

class BusinessLedgerScreen extends ConsumerWidget {
  const BusinessLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactions = ref.watch(transactionProvider);
    final pantryItems = ref.watch(pantryProvider);
    final txNotifier = ref.read(transactionProvider.notifier);

    final totalExpenses = txNotifier.getTotal('expense');
    final totalSales = txNotifier.getTotal('sale');

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
            _buildLowStockAlerts(context, pantryItems),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildQuickAction(
                    context, ref, l10n.manageDatabase, Icons.storage, const Color(0xFF8C6F1D), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PantryManagementScreen()),
                      );
                    }),
                const SizedBox(width: 12),
                _buildQuickAction(
                    context, ref, l10n.addSale, Icons.add_shopping_cart, ArtisanalTheme.primary, () {
                      _showSalesSlip(context);
                    }),
                const SizedBox(width: 12),
                _buildQuickAction(
                    context, ref, l10n.exportPdf, Icons.picture_as_pdf, const Color(0xFF8C6F1D), () {}),
              ],
            ),
            const SizedBox(height: 40),
            _buildSerratedLedgerCard(
                context, totalExpenses, totalSales, transactions, pantryItems),
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

  Widget _buildQuickAction(BuildContext context, WidgetRef ref, String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: ArtisanalTheme.background, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: ArtisanalTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSerratedLedgerCard(
      BuildContext context,
      double totalExpenses,
      double totalSales,
      List<dynamic> transactions,
      List<dynamic> pantryItems) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);
    final monthName = DateFormat('MMMM').format(DateTime.now());

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 40,
                    offset: const Offset(0, 12))
              ],
            ),
            child: ClipPath(
              clipper: SerratedClipper(),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
                child: Column(
                  children: [
                    // Receipt Header
                    _buildLedgerSectionTitle(
                        context, l10n.ingredientLedger, null,
                        onTrailingTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseHistoryScreen()));
                        }),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(totalExpenses),
                      style: ArtisanalTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(fontSize: 40, color: ArtisanalTheme.primary),
                    ),
                    Text(
                      '${l10n.totalMonthlySpend} ($monthName)',
                      style: ArtisanalTheme.lightTheme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.black38),
                    ),
                    const SizedBox(height: 32),
                    _dottedDivider(),
                    const SizedBox(height: 24),

                    const SizedBox(height: 32),
                    _dottedDivider(),
                    const SizedBox(height: 24),

                    // Recent Purchases (Filtering only expenses)
                    _buildLedgerSectionTitle(
                        context, l10n.recentPurchases.toUpperCase(), null, 
                        onTrailingTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseHistoryScreen()));
                        }),
                    const SizedBox(height: 16),
                    (() {
                      final expenses = transactions.where((tx) => tx.type == 'expense').toList()
                        ..sort((a, b) => b.date.compareTo(a.date));
                      
                      if (expenses.isEmpty) {
                        return Text(l10n.noPurchaseRecords, style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black26));
                      }
                      
                      return Column(
                        children: expenses.take(3).map((tx) => _buildDisbursementItem(
                            DateFormat('dd MMM yyyy').format(tx.date),
                            tx.description,
                            currencyFormat.format(tx.amount),
                            false // Expenses are always negative/red here
                        )).toList(),
                      );
                    })(),

                    const SizedBox(height: 48),
                    _dottedDivider(),
                    const SizedBox(height: 24),

                    // Barcode Section
                    _buildBarcode(),
                    const SizedBox(height: 8),
                    Text('00293 84729 11029',
                        style: ArtisanalTheme.hand(fontSize: 12, color: Colors.black38)
                            .copyWith(letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
        // The Tape
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(child: WashiTape(width: 80, rotation: -0.05)),
        ),
        // Red Marker Note
        Positioned(
          top: 50,
          right: 20,
          child: Transform.rotate(
            angle: -0.1,
            child: Text(
              l10n.review,
              style: ArtisanalTheme.hand(
                      fontSize: 20, color: const Color(0xFFBA1A1A))
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dottedDivider() {
    return Row(
      children: List.generate(
          30,
          (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 1,
                  color: index % 2 == 0 ? Colors.black12 : Colors.transparent,
                ),
              )),
    );
  }

  Widget _buildBarcode() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            40,
            (index) => Container(
                  width: (index % 3 == 0) ? 3 : 1,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 30,
                  color: index % 5 == 0 ? Colors.transparent : Colors.black87,
                )),
      ),
    );
  }

  Widget _buildLedgerSectionTitle(
      BuildContext context, String title, IconData? icon, {VoidCallback? onTrailingTap}) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: ArtisanalTheme.secondary),
          const SizedBox(width: 8)
        ],
        Text(title,
            style: ArtisanalTheme.lightTheme.textTheme.displaySmall
                ?.copyWith(fontSize: 18, fontStyle: FontStyle.italic)),
        const Spacer(),
        if (onTrailingTap != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              l10n.history,
              style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.primary.withValues(alpha: 0.6)),
            ),
          ),
      ],
    );
  }

  Widget _buildVaultItem(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: ArtisanalTheme.hand(
                  fontSize: 16, 
                  color: isWarning ? ArtisanalTheme.primary : Colors.black87
                )),
          ),
          Text(value,
              style: ArtisanalTheme.hand(
                fontSize: 16, 
                color: isWarning ? ArtisanalTheme.primary : Colors.black54,
                fontWeight: isWarning ? FontWeight.bold : FontWeight.normal
              )),
        ],
      ),
    );
  }

  Widget _buildDisbursementItem(
      String date, String description, String amount, bool isSale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: ArtisanalTheme.lightTheme.textTheme.labelSmall
                        ?.copyWith(color: Colors.black26)),
                Text(description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ArtisanalTheme.lightTheme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isSale ? "+$amount" : "-$amount",
            style: ArtisanalTheme.hand(
                fontSize: 18,
                color: isSale ? Colors.green.shade800 : ArtisanalTheme.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlerts(BuildContext context, List<PantryItem> items) {
    final l10n = AppLocalizations.of(context);
    final lowStockItems = items.where((item) {
      final percent = item.purchaseQuantity > 0 ? (item.currentStock / item.purchaseQuantity) : 0.0;
      return percent < 0.2;
    }).toList();

    if (lowStockItems.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArtisanalTheme.redInk.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ArtisanalTheme.redInk.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: ArtisanalTheme.redInk, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.lowStockAlert,
                style: ArtisanalTheme.hand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ArtisanalTheme.redInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.restockNow,
            style: ArtisanalTheme.hand(
              fontSize: 14,
              color: ArtisanalTheme.redInk.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: lowStockItems.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ArtisanalTheme.redInk.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: ArtisanalTheme.hand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ArtisanalTheme.redInk,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${(item.currentStock / 1000).toStringAsFixed(1)}kg",
                    style: ArtisanalTheme.hand(
                      fontSize: 12,
                      color: ArtisanalTheme.redInk.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
