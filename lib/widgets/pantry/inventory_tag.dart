import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_atelier/providers/pantry_categories_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/artisanal_theme.dart';
import '../../models/pantry_item.dart';
import '../../l10n/app_localizations.dart';

class InventoryTag extends ConsumerWidget {
  final PantryItem item;
  const InventoryTag({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final categoriesMap = ref.watch(pantryCategoriesProvider);
    final stockPercent =
        (item.currentStock /
                (item.targetQuantity > 0 ? item.targetQuantity : 1))
            .clamp(0.0, 1.0);
    final isLow = stockPercent < 0.2;

    // Get Dynamic Post-it Color from Provider
    final noteColorValue =
        categoriesMap[item.category] ?? 0xFFFFF9C4; // Fallback to Yellow
    final noteColor = Color(noteColorValue);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Subtle Edge Curl Shadow
        Positioned(
          bottom: 2,
          right: 4,
          child: Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
          ),
        ),

        // Post-it Body
        Transform.rotate(
          angle: (item.id.hashCode % 10 - 5) / 180, // Subtle random tilt
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: noteColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(
                  item.id.hashCode % 2 == 0 ? 20 : 2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.name.toUpperCase(),
                      style: ArtisanalTheme.hand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ArtisanalTheme.ink,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Category Annotation
                  Text(
                    "#${item.category}",
                    style: ArtisanalTheme.hand(
                      fontSize: 8,
                      color: ArtisanalTheme.secondary.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Stock Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.formatWeight(item.currentStock, item.unit),
                            style: ArtisanalTheme.hand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLow
                                  ? ArtisanalTheme.redInk
                                  : ArtisanalTheme.ink,
                            ),
                          ),
                          Text(
                            "/ ${settings.formatWeight(item.targetQuantity, item.unit)}",
                            style: ArtisanalTheme.hand(
                              fontSize: 10,
                              color: ArtisanalTheme.secondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (isLow) _buildUrgentMarker(l10n),
                    ],
                  ),

                  const SizedBox(height: 4),
                  _buildHandDrawnProgress(stockPercent, isLow),
                ],
              ),
            ),
          ),
        ),

        // Options icon moved to top right
        Positioned(
          top: 14,
          right: 14,
          child: Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.more_horiz,
              size: 14,
              color: ArtisanalTheme.ink,
            ),
          ),
        ),

        // Masking Tape on top
        Positioned(
          top: -8,
          left: 0,
          right: 0,
          child: Center(child: _buildMaskingTape(item.id.hashCode)),
        ),
      ],
    );
  }

  Widget _buildMaskingTape(int seed) {
    return Transform.rotate(
      angle: (seed % 10 - 5) / 100,
      child: Container(
        width: 50,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(
            0xFFFDF5E6,
          ).withValues(alpha: 0.7), // Semi-transparent paper tape
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: CustomPaint(painter: TapeTexturePainter()),
      ),
    );
  }

  Widget _buildUrgentMarker(AppLocalizations l10n) {
    return Transform.rotate(
      angle: -0.2,
      child: Text(
        "!!!",
        style: ArtisanalTheme.hand(
          color: ArtisanalTheme.redInk,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHandDrawnProgress(double percent, bool isLow) {
    return Column(
      children: [
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    color: isLow
                        ? ArtisanalTheme.redInk.withValues(alpha: 0.5)
                        : ArtisanalTheme.ink.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // "Scribble" lines on the progress
              Positioned.fill(
                child: CustomPaint(painter: ScribblePainter(percent)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${(percent * 100).toStringAsFixed(0)}%",
              style: ArtisanalTheme.hand(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isLow
                    ? ArtisanalTheme.redInk.withValues(alpha: 0.6)
                    : ArtisanalTheme.secondary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ScribblePainter extends CustomPainter {
  final double percent;
  ScribblePainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    if (percent <= 0) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    final double endX = size.width * percent;
    for (double x = 0; x < endX; x += 4) {
      canvas.drawLine(Offset(x, 0), Offset(x + 2, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ScribblePainter oldDelegate) => false;
}

class TapeTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    // Horizontal lines for paper fiber look
    for (double y = 2; y < size.height; y += 3) {
      canvas.drawLine(Offset(2, y), Offset(size.width - 2, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
