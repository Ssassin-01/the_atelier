import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import 'masking_tape.dart';

class ArtisanalCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action; // New optional action widget
  final double rotation;
  final String? tapeLabel;
  final Color? tapeColor;

  const ArtisanalCard({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.rotation = 0,
    this.tapeLabel,
    this.tapeColor = const Color(0xFFEEE7D1),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFCF7), // Light cream paper
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(4, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 2,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: ArtisanalTheme.hand(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: ArtisanalTheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    if (action != null) action!,
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 1,
                  width: 30,
                  color: ArtisanalTheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
          if (tapeLabel != null)
            Positioned(
              top: -15,
              right: 30,
              child: MaskingTape(
                width: 90,
                label: tapeLabel,
                rotation: 0.08,
                color: tapeColor!,
              ),
            ),
        ],
      ),
    );
  }
}
