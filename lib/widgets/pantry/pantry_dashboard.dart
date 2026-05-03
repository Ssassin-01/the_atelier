import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/artisanal_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

class PantryDashboard extends ConsumerWidget {
  final double totalVaultValue;
  final int urgentCount;
  final int missingInfoCount;
  final int totalEntries;
  final String activeFilter;
  final VoidCallback onTotalTap;
  final VoidCallback onLowStockTap;
  final VoidCallback onMissingInfoTap;
  final bool isCompressed;

  const PantryDashboard({
    super.key,
    required this.totalVaultValue,
    required this.urgentCount,
    required this.missingInfoCount,
    required this.totalEntries,
    required this.activeFilter,
    required this.onTotalTap,
    required this.onLowStockTap,
    required this.onMissingInfoTap,
    this.isCompressed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (isCompressed) {
      return _buildCompressed(context, ref, l10n);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tape Decorations for Concept 1
          Positioned(top: -10, left: 10, child: _buildTape(30, -0.1)),
          Positioned(bottom: -5, right: 15, child: _buildTape(40, 0.05)),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: ArtisanalTheme.ink.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (ref.watch(settingsProvider).isBusinessMode)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.inventoryValueReport.toUpperCase(),
                                style: ArtisanalTheme.hand(
                                  color: ArtisanalTheme.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                                  letterSpacing: 2.0,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  _showCalculationInfo(context, l10n);
                                },
                                child: Icon(
                                  Icons.info_outline,
                                  size: 12,
                                  color: ArtisanalTheme.secondary.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ref.watch(settingsProvider).format(totalVaultValue),
                            style: ArtisanalTheme.hand(
                              fontWeight: FontWeight.w900,
                              color: ArtisanalTheme.ink,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.pantryLedger.toUpperCase(),
                            style: ArtisanalTheme.hand(
                              color: ArtisanalTheme.secondary.withValues(
                                alpha: 0.5,
                              ),
                              letterSpacing: 2.0,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.stable.toUpperCase(),
                            style: ArtisanalTheme.hand(
                              fontWeight: FontWeight.w900,
                              color: ArtisanalTheme.ink,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                    Icon(
                      Icons.auto_graph_outlined,
                      color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  color: ArtisanalTheme.ink.withValues(alpha: 0.05),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModernStat(
                      l10n.totalEntries,
                      totalEntries.toString(),
                      onTap: onTotalTap,
                      isSelected: activeFilter == 'all',
                    ),
                    _buildModernStat(
                      l10n.lowStock,
                      urgentCount.toString(),
                      isAlert: urgentCount > 0,
                      onTap: onLowStockTap,
                      isSelected: activeFilter == 'lowStock',
                    ),
                    if (ref.watch(settingsProvider).isBusinessMode)
                      _buildModernStat(
                        l10n.missingInfo,
                        missingInfoCount.toString(),
                        isAlert: missingInfoCount > 0,
                        onTap: onMissingInfoTap,
                        isSelected: activeFilter == 'missingInfo',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompressed(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        border: Border(
          bottom: BorderSide(color: ArtisanalTheme.ink.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (ref.watch(settingsProvider).isBusinessMode)
                Text(
                  ref.watch(settingsProvider).format(totalVaultValue),
                  style: ArtisanalTheme.hand(
                    fontWeight: FontWeight.w900,
                    color: ArtisanalTheme.ink,
                    fontSize: 20,
                  ),
                )
              else
                Text(
                  l10n.pantry.toUpperCase(),
                  style: ArtisanalTheme.hand(
                    fontWeight: FontWeight.w900,
                    color: ArtisanalTheme.ink,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 12,
                color: ArtisanalTheme.ink.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 12),
              Text(
                "${l10n.totalEntries}: $totalEntries",
                style: ArtisanalTheme.hand(
                  fontSize: 12,
                  color: ArtisanalTheme.secondary,
                ),
              ),
            ],
          ),
          if (urgentCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ArtisanalTheme.redInk.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "! $urgentCount",
                style: ArtisanalTheme.hand(
                  color: ArtisanalTheme.redInk,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTape(double width, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: 14,
        decoration: BoxDecoration(
          color: const Color(0xFFFDF5E6).withValues(alpha: 0.5),
          border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        ),
      ),
    );
  }

  Widget _buildModernStat(
    String label,
    String value, {
    bool isAlert = false,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.selectionClick();
          onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ArtisanalTheme.ink.withValues(alpha: 0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: ArtisanalTheme.hand(
                fontWeight: FontWeight.bold,
                color: isAlert ? ArtisanalTheme.redInk : ArtisanalTheme.ink,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: ArtisanalTheme.hand(
                color: isSelected
                    ? ArtisanalTheme.ink
                    : ArtisanalTheme.secondary.withValues(alpha: 0.4),
                letterSpacing: 1.0,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalculationInfo(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Row(
          children: [
            const Icon(Icons.calculate_outlined, size: 20, color: ArtisanalTheme.ink),
            const SizedBox(width: 8),
            Text(
              "자산 가치 계산 방식",
              style: ArtisanalTheme.hand(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "현재 보유한 재고의 가치를 아래 공식으로 계산합니다:",
              style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.secondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ArtisanalTheme.ink.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "(구매 가격 ÷ 구매 시 수량) × 현재 실재고",
                textAlign: TextAlign.center,
                style: ArtisanalTheme.receipt(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: ArtisanalTheme.ink,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "* 구매 시 수량이 0인 경우, 설정된 최소 유지 재고를 기준으로 계산합니다 (호환용).",
              style: ArtisanalTheme.hand(
                fontSize: 11,
                color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "확인",
              style: ArtisanalTheme.hand(fontWeight: FontWeight.bold, color: ArtisanalTheme.ink),
            ),
          ),
        ],
      ),
    );
  }
}
