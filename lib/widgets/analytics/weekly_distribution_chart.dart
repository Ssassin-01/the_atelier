import 'package:flutter/material.dart';
import '../../theme/artisanal_theme.dart';

class WeeklyDistributionChart extends StatelessWidget {
  final Map<int, double> weekdaySales;

  const WeeklyDistributionChart({super.key, required this.weekdaySales});

  @override
  Widget build(BuildContext context) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    
    double maxAmount = 0;
    weekdaySales.forEach((_, amount) {
      if (amount > maxAmount) maxAmount = amount;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "요일별 매출 분포",
          style: ArtisanalTheme.note(fontSize: 12, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
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
                    amount > 0 ? "${(amount / 10000).toStringAsFixed(0)}만" : "",
                    style: ArtisanalTheme.hand(fontSize: 10, color: ArtisanalTheme.ink.withValues(alpha: 0.4)),
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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    days[index],
                    style: ArtisanalTheme.note(
                      fontSize: 12, 
                      fontWeight: weekday > 5 ? FontWeight.bold : FontWeight.normal,
                      color: weekday > 5 ? ArtisanalTheme.redInk : ArtisanalTheme.ink,
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
}
