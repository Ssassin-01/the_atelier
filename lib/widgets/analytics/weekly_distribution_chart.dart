import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/artisanal_theme.dart';
import '../../providers/settings_provider.dart';

class WeeklyDistributionChart extends ConsumerWidget {
  final Map<int, double> weekdaySales;

  const WeeklyDistributionChart({super.key, required this.weekdaySales});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final settings = ref.watch(settingsProvider);

    double maxAmount = 0;
    weekdaySales.forEach((_, amount) {
      if (amount > maxAmount) maxAmount = amount;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "요일별 매출 분포",
          style: ArtisanalTheme.note(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: ArtisanalTheme.ink.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            final weekday = index + 1; // 1 (Mon) to 7 (Sun)
            final amount = weekdaySales[weekday] ?? 0;
            final heightFactor = maxAmount > 0 ? amount / maxAmount : 0.0;

            return Expanded(
              child: Column(
                children: [
                  Text(
                    _formatAmount(amount, settings),
                    style: ArtisanalTheme.hand(
                      fontSize: 10,
                      color: ArtisanalTheme.ink.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: (heightFactor * 100).clamp(4, 100).toDouble(),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ArtisanalTheme.primary.withValues(alpha: 0.8),
                          ArtisanalTheme.primary.withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    days[index],
                    style: ArtisanalTheme.note(
                      fontSize: 12,
                      fontWeight: weekday > 5
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: weekday > 5
                          ? ArtisanalTheme.redInk
                          : ArtisanalTheme.ink,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  String _formatAmount(double amount, SettingsState settings) {
    if (amount <= 0) return "";
    final isLargeUnit = settings.currencySymbol == '₩' || 
                       settings.currencySymbol == '¥' || 
                       settings.currencySymbol == '￥' ||
                       settings.currencySymbol == String.fromCharCode(8361);
    if (isLargeUnit) {
      if (amount >= 10000) {
        return "${(amount / 10000).toStringAsFixed(0)}만";
      }
      return amount.toStringAsFixed(0);
    } else {
      if (amount >= 1000) {
        return "${settings.currencySymbol}${(amount / 1000).toStringAsFixed(1)}K";
      }
      return "${settings.currencySymbol}${amount.toStringAsFixed(0)}";
    }
  }
}
