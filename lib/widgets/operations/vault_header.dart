import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/artisanal_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transaction.dart';

class VaultHeader extends StatelessWidget {
  final List<BusinessTransaction> transactions;

  const VaultHeader({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol, decimalDigits: 0);
    
    final now = DateTime.now();
    final monthlyTxs = transactions.where((tx) => 
      tx.date.month == now.month && tx.date.year == now.year).toList();

    double totalSales = 0;
    double totalExpenses = 0;

    for (var tx in monthlyTxs) {
      if (tx.type == 'sale') {
        totalSales += tx.amount;
      } else {
        totalExpenses += tx.amount;
      }
    }

    final netProfit = totalSales - totalExpenses;
    final isProfit = netProfit >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/paper-fibers.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.monthlyOverview.toUpperCase(),
                style: ArtisanalTheme.hand(
                  fontSize: 14,
                  color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(netProfit),
                style: ArtisanalTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  fontSize: 38,
                  color: isProfit ? ArtisanalTheme.primary : ArtisanalTheme.redInk,
                  height: 1.0,
                ),
              ),
              Text(
                l10n.netProfitLabel,
                style: ArtisanalTheme.hand(
                  fontSize: 18,
                  color: ArtisanalTheme.ink.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniStat(
                    context, 
                    l10n.totalRevenue, 
                    "+${currencyFormat.format(totalSales)}", 
                    ArtisanalTheme.greenInk.withValues(alpha: 0.9)
                  ),
                  const SizedBox(width: 24),
                  _buildMiniStat(
                    context, 
                    l10n.totalExpensesLabel, 
                    "-${currencyFormat.format(totalExpenses)}", 
                    ArtisanalTheme.redInk.withValues(alpha: 0.9)
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (isProfit ? ArtisanalTheme.primary : ArtisanalTheme.redInk).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isProfit ? l10n.profitVerified : l10n.deficitNoted,
                  style: ArtisanalTheme.hand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: (isProfit ? ArtisanalTheme.primary : ArtisanalTheme.redInk).withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ArtisanalTheme.hand(
            fontSize: 12,
            color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: ArtisanalTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
