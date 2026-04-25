import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';

class ArtisanalBarcode extends StatelessWidget {
  final String code;
  final double height;

  const ArtisanalBarcode({
    super.key,
    this.code = '00293 84729 11029',
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                40,
                (index) => Container(
                      width: (index % 3 == 0) ? 3 : 1,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: height * 0.75,
                      color: index % 5 == 0 ? Colors.transparent : Colors.black87,
                    )),
          ),
        ),
        const SizedBox(height: 8),
        if (code.isNotEmpty)
          Text(
            code,
            style: ArtisanalTheme.hand(fontSize: 12, color: Colors.black38)
                .copyWith(letterSpacing: 2),
          ),
      ],
    );
  }
}
