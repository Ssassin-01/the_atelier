import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/artisanal_theme.dart';
import '../../providers/settings_provider.dart';

class MonthlyCostAnalysis extends ConsumerWidget {
  final double fixedCosts;
  final double variableCosts;

  const MonthlyCostAnalysis({
    super.key,
    required this.fixedCosts,
    required this.variableCosts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = fixedCosts + variableCosts;
    final fixedRatio = total > 0 ? fixedCosts / total : 0.0;
    final variableRatio = total > 0 ? variableCosts / total : 0.0;
    final settings = ref.watch(settingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "비용 구조 분석",
          style: ArtisanalTheme.note(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: ArtisanalTheme.ink.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 32,
            child: Row(
              children: [
                if (fixedRatio > 0)
                  Expanded(
                    flex: (fixedRatio * 100).toInt(),
                    child: Container(
                      color: ArtisanalTheme.redInk.withValues(alpha: 0.6),
                    ),
                  ),
                if (variableRatio > 0)
                  Expanded(
                    flex: (variableRatio * 100).toInt(),
                    child: Container(
                      color: ArtisanalTheme.redInk.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildLegendItem(
              "고정비 (임대료 등)",
              fixedRatio,
              ArtisanalTheme.redInk.withValues(alpha: 0.6),
              settings.format(fixedCosts),
            ),
            const Spacer(),
            _buildLegendItem(
              "가변비 (재료비 등)",
              variableRatio,
              ArtisanalTheme.redInk.withValues(alpha: 0.2),
              settings.format(variableCosts),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String label,
    double ratio,
    Color color,
    String amount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: ArtisanalTheme.note(
                fontSize: 10,
                color: ArtisanalTheme.ink.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${(ratio * 100).toStringAsFixed(1)}% ($amount)",
          style: ArtisanalTheme.hand(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ArtisanalTheme.ink,
          ),
        ),
      ],
    );
  }
}
