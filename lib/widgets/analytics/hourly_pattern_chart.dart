import 'package:flutter/material.dart';
import '../../theme/artisanal_theme.dart';

class HourlyPatternChart extends StatelessWidget {
  final Map<int, double> hourlySales;

  const HourlyPatternChart({super.key, required this.hourlySales});

  @override
  Widget build(BuildContext context) {
    // Find the busiest hour
    int maxHour = -1;
    double maxAmount = 0;
    hourlySales.forEach((hour, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        maxHour = hour;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "가장 활기찬 시간대",
          style: ArtisanalTheme.note(fontSize: 12, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(24, (index) {
              final amount = hourlySales[index] ?? 0;
              final heightFactor = maxAmount > 0 ? amount / maxAmount : 0.0;
              final isPeak = index == maxHour;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: (heightFactor * 70).clamp(2, 70).toDouble(),
                        decoration: BoxDecoration(
                          color: isPeak ? ArtisanalTheme.primary : ArtisanalTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (index % 6 == 0)
                        Text(
                          "$index",
                          style: ArtisanalTheme.note(fontSize: 8, color: ArtisanalTheme.ink.withValues(alpha: 0.3)),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        if (maxHour != -1) ...[
          const SizedBox(height: 16),
          Text(
            "오늘 오후 ${maxHour > 12 ? maxHour - 12 : maxHour}시경에 가장 바빴습니다.",
            style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.primary, fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}
