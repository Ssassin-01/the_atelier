import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/artisanal_theme.dart';

class PopularItemsList extends StatelessWidget {
  final List<MapEntry<String, double>> items;

  const PopularItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'ko_KR', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "이달의 인기 품목",
          style: ArtisanalTheme.note(fontSize: 12, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 16),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: index == 0 ? ArtisanalTheme.primary : ArtisanalTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: ArtisanalTheme.note(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        color: index == 0 ? Colors.white : ArtisanalTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.key,
                    style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.ink),
                  ),
                ),
                Text(
                  currencyFormat.format(item.value),
                  style: ArtisanalTheme.note(fontSize: 14, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
