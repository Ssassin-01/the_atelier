import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_clippers.dart';
import '../widgets/sales_slip_sheet.dart';

class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allTransactions = ref.watch(transactionProvider);
    final sales = allTransactions.where((tx) => tx.type == 'sale').toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group by date
    Map<String, List<BusinessTransaction>> grouped = {};
    for (var sale in sales) {
      final dateStr = DateFormat('yyyy. MM. dd (EEE)').format(sale.date);
      grouped.putIfAbsent(dateStr, () => []).add(sale);
    }

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      appBar: AppBar(
        title: Text(l10n.salesHistory, style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: sales.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final dateKey = grouped.keys.elementAt(index);
                final daySales = grouped[dateKey]!;
                return _buildDateGroup(context, ref, dateKey, daySales);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 64, color: ArtisanalTheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(l10n.noSalesRecords, style: ArtisanalTheme.hand(fontSize: 18, color: Colors.black26)),
        ],
      ),
    );
  }

  Widget _buildDateGroup(BuildContext context, WidgetRef ref, String dateKey, List<BusinessTransaction> daySales) {
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);
    final dayTotal = daySales.fold(0.0, (sum, tx) => sum + tx.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateKey,
                style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.secondary, fontWeight: FontWeight.bold),
              ),
              Text(
                "Total: ${currencyFormat.format(dayTotal)}",
                style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...daySales.map((tx) => _buildSaleCard(context, ref, tx)),
        const SizedBox(height: 24),
      ],
    );
  }
  Widget _buildSaleCard(BuildContext context, WidgetRef ref, BusinessTransaction tx) {
    final currencyFormat = NumberFormat.currency(symbol: '₩', decimalDigits: 0);

    return GestureDetector(
      onTap: () => _showEditSlip(context, tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipPath(
          clipper: SerratedClipper(toothWidth: 10, toothHeight: 4, top: false, bottom: true),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: ArtisanalTheme.primary, width: 4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description,
                        style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(tx.date),
                        style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black26),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(tx.amount),
                  style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.primary),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: ArtisanalTheme.redInk.withValues(alpha: 0.3)),
                  onPressed: () => _confirmDelete(context, ref, tx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSlip(BuildContext context, BusinessTransaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SalesSlipSheet(initialTransaction: tx),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, BusinessTransaction tx) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord, style: ArtisanalTheme.hand(fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: ArtisanalTheme.hand(color: Colors.black38)),
          ),
          TextButton(
            onPressed: () {
              ref.read(transactionProvider.notifier).deleteTransaction(tx.id);
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: ArtisanalTheme.hand(color: ArtisanalTheme.redInk)),
          ),
        ],
      ),
    );
  }
}
