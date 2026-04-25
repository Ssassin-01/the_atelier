import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_clippers.dart';
import '../widgets/masking_tape.dart';
import '../widgets/artisanal_barcode.dart';

class SerratedLedgerCard extends StatelessWidget {
  final double totalExpenses;
  final List<dynamic> transactions;
  final VoidCallback onHistoryTap;

  const SerratedLedgerCard({
    super.key,
    required this.totalExpenses,
    required this.transactions,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    _buildSectionHeader(context, l10n.ingredientLedger, onHistoryTap),
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
                    const SizedBox(height: 32),
                    _buildSectionHeader(context, l10n.recentPurchases.toUpperCase(), onHistoryTap),
                    const SizedBox(height: 16),
                    _buildExpenseList(transactions, l10n, currencyFormat),
                    const SizedBox(height: 48),
                    _dottedDivider(),
                    const SizedBox(height: 24),
                    const ArtisanalBarcode(),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(child: MaskingTape(width: 80, rotation: -0.05)),
        ),
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

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      children: [
        Text(title,
            style: ArtisanalTheme.lightTheme.textTheme.displaySmall
                ?.copyWith(fontSize: 18, fontStyle: FontStyle.italic)),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Text(
            AppLocalizations.of(context).history,
            style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.primary.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList(List<dynamic> transactions, AppLocalizations l10n, NumberFormat format) {
    final expenses = transactions.where((tx) => tx.type == 'expense').toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    if (expenses.isEmpty) {
      return Text(l10n.noPurchaseRecords, 
          style: ArtisanalTheme.hand(fontSize: 14, color: Colors.black26));
    }
    
    return Column(
      children: expenses.take(3).map((tx) => _buildDisbursementItem(
          DateFormat('dd MMM yyyy').format(tx.date),
          tx.description,
          format.format(tx.amount)
      )).toList(),
    );
  }

  Widget _buildDisbursementItem(String date, String description, String amount) {
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
            "-$amount",
            style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
          ),
        ],
      ),
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
}
