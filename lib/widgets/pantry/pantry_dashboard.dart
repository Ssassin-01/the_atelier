import 'package:flutter/material.dart';
import '../../theme/artisanal_theme.dart';
import '../../l10n/app_localizations.dart';

class PantryDashboard extends StatelessWidget {
  final double totalVaultValue;
  final int urgentCount;
  final int missingInfoCount;
  final int totalEntries;

  const PantryDashboard({
    super.key,
    required this.totalVaultValue,
    required this.urgentCount,
    required this.missingInfoCount,
    required this.totalEntries,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFCFB),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: const Color(0xFFE5E0D8), width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.totalVaultValue.toUpperCase(), 
                      style: ArtisanalTheme.hand(fontSize: 10, color: ArtisanalTheme.secondary, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text("₩ ${totalVaultValue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}", 
                      style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E0D8)),
                  ),
                  child: Column(
                    children: [
                      Text(l10n.inventoryStatus.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 8, color: ArtisanalTheme.secondary)),
                      Text(urgentCount > 0 ? l10n.urgent.toUpperCase() : l10n.stable.toUpperCase(), 
                        style: ArtisanalTheme.hand(fontSize: 12, fontWeight: FontWeight.bold, 
                        color: urgentCount > 0 ? ArtisanalTheme.redInk : Colors.green.shade700)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1, color: Color(0xFFE5E0D8)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDashboardStat(l10n.lowStock.toUpperCase(), urgentCount.toString(), ArtisanalTheme.redInk),
                _buildDashboardStat(l10n.missingInfo.toUpperCase(), missingInfoCount.toString(), Colors.orange.shade700),
                _buildDashboardStat(l10n.totalEntries.toUpperCase(), totalEntries.toString(), ArtisanalTheme.ink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: ArtisanalTheme.hand(fontSize: 8, color: ArtisanalTheme.secondary)),
        const SizedBox(height: 2),
        Text(value, style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
