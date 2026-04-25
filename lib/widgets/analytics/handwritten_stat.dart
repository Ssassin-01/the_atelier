import 'package:flutter/material.dart';
import '../../theme/artisanal_theme.dart';

class HandwrittenStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const HandwrittenStat({
    super.key,
    required this.label,
    required this.value,
    this.color = ArtisanalTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ArtisanalTheme.hand(fontSize: 11, color: Colors.black26, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: ArtisanalTheme.hand(
                fontSize: 36,
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
              ).copyWith(letterSpacing: -1.5),
            ),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 2,
              width: 30,
              color: color.withValues(alpha: 0.15),
            ),
          ],
        ),
      ],
    );
  }
}
