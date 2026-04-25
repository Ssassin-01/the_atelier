import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/artisanal_theme.dart';
import '../../providers/analytics_provider.dart';

class InventoryDistributionChart extends ConsumerWidget {
  const InventoryDistributionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final categoryCounts = analytics.inventoryDistribution;
    final categories = categoryCounts.keys.toList();
    
    final colors = [
      ArtisanalTheme.primary.withValues(alpha: 0.7),
      const Color(0xFFD4C8A1),
      ArtisanalTheme.redInk.withValues(alpha: 0.5),
      const Color(0xFFC4B69C),
      const Color(0xFFAFA590),
      Colors.grey.withValues(alpha: 0.3),
    ];

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 35,
              sections: List.generate(categories.length, (i) {
                final category = categories[i];
                final count = categoryCounts[category]!;

                return PieChartSectionData(
                  color: colors[i % colors.length],
                  value: count.toDouble(),
                  title: '',
                  radius: 40,
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(categories.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      categories[i],
                      style: ArtisanalTheme.hand(fontSize: 12, color: Colors.black45),
                    ),
                    const Spacer(),
                    Text(
                      '${categoryCounts[categories[i]]}',
                      style: ArtisanalTheme.hand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
