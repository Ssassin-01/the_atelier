import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/artisanal_theme.dart';
import '../../l10n/app_localizations.dart';

class PantryDashboard extends StatelessWidget {
  final double totalVaultValue;
  final int urgentCount;
  final int missingInfoCount;
  final int totalEntries;
  final VoidCallback? onTotalTap;
  final VoidCallback? onLowStockTap;
  final VoidCallback? onMissingInfoTap;
  final String activeFilter; // 'all', 'lowStock', 'missingInfo'

  const PantryDashboard({
    super.key,
    required this.totalVaultValue,
    required this.urgentCount,
    required this.missingInfoCount,
    required this.totalEntries,
    this.onTotalTap,
    this.onLowStockTap,
    this.onMissingInfoTap,
    this.activeFilter = 'all',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDFCFB),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Certificate Border
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD4C4A1), width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD4C4A1), width: 1.5),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      children: [
                        // Header Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Container(
                               height: 1,
                               width: 40,
                               color: const Color(0xFFD4C4A1),
                             ),
                             const SizedBox(width: 12),
                             Text(
                               l10n.inventoryValueReport.toUpperCase(),
                               style: ArtisanalTheme.hand(
                                 fontSize: 10,
                                 color: ArtisanalTheme.secondary,
                                 letterSpacing: 2.0,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             const SizedBox(width: 12),
                             Container(
                               height: 1,
                               width: 40,
                               color: const Color(0xFFD4C4A1),
                             ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Main Value
                        Text(
                          "${l10n.currencySymbol}${totalVaultValue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: ArtisanalTheme.lightTheme.textTheme.displaySmall?.copyWith(
                            fontSize: 36,
                            color: ArtisanalTheme.ink,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          "ESTIMATED TOTAL ASSET VALUE",
                          style: ArtisanalTheme.hand(
                            fontSize: 9,
                            color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                            letterSpacing: 1.0,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFE8D7A5)),
                        const SizedBox(height: 20),
                        
                        // Stats Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCertStat(
                              l10n.totalEntries, 
                              totalEntries.toString(),
                              onTap: onTotalTap,
                              isSelected: activeFilter == 'all',
                            ),
                            _buildCertStat(
                              l10n.lowStock, 
                              urgentCount.toString(), 
                              isAlert: urgentCount > 0,
                              onTap: onLowStockTap,
                              isSelected: activeFilter == 'lowStock',
                            ),
                            _buildCertStat(
                              l10n.missingInfo, 
                              missingInfoCount.toString(),
                              onTap: onMissingInfoTap,
                              isSelected: activeFilter == 'missingInfo',
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Bottom Signature Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ISSUED BY",
                                  style: ArtisanalTheme.hand(fontSize: 8, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "ATELIER MASTER",
                                  style: ArtisanalTheme.hand(
                                    fontSize: 16,
                                    color: ArtisanalTheme.ink.withValues(alpha: 0.7),
                                  ),
                                ),
                                Container(height: 1, width: 100, color: Colors.black12),
                              ],
                            ),
                            Transform.rotate(
                              angle: -0.1,
                              child: Icon(
                                Icons.verified_user_outlined,
                                size: 40,
                                color: ArtisanalTheme.primary.withValues(alpha: 0.1),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Official Seal Overlay
            Positioned(
              right: 15,
              top: 15,
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ArtisanalTheme.primary, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      "VALD",
                      style: ArtisanalTheme.hand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ArtisanalTheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertStat(String label, String value, {bool isAlert = false, VoidCallback? onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.selectionClick();
          onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ArtisanalTheme.primary.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? ArtisanalTheme.primary.withValues(alpha: 0.2) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: ArtisanalTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: isAlert ? ArtisanalTheme.redInk : ArtisanalTheme.ink,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: ArtisanalTheme.hand(
                fontSize: 9,
                color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                color: ArtisanalTheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

