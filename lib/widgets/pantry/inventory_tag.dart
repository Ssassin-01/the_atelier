import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/artisanal_theme.dart';
import '../../models/pantry_item.dart';
import '../../l10n/app_localizations.dart';

class InventoryTag extends ConsumerWidget {
  final PantryItem item;
  final VoidCallback onRestock;
  
  const InventoryTag({
    super.key, 
    required this.item,
    required this.onRestock,
  });

  Color _getPostItColor(String category) {
    switch (category) {
      case 'Flour': return const Color(0xFFFFF9C4); // Yellow
      case 'Dairy/Eggs': return const Color(0xFFF8BBD0); // Pink
      case 'Sweetener': return const Color(0xFFB3E5FC); // Blue
      case 'Leavening': return const Color(0xFFC8E6C9); // Green
      case 'Add-in': return const Color(0xFFFFCCBC); // Orange
      default: return const Color(0xFFE1BEE7); // Purple
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stockPercent = (item.currentStock / (item.targetQuantity > 0 ? item.targetQuantity : 1)).clamp(0.0, 1.0);
    final isLow = stockPercent < 0.2;
    final noteColor = _getPostItColor(item.category);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Post-it Body
        Transform.rotate(
          angle: (item.id.hashCode % 10 - 5) / 150, // Subtle random tilt
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: noteColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(item.id.hashCode % 2 == 0 ? 24 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
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
                        fontSize: 15, // Slightly smaller
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
                      fontSize: 8, // Slightly smaller
                      color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  const SizedBox(height: 2), // Smaller
                  
                  // Stock Info in Hand-drawn style
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.currentStock.toInt()}${item.unit}",
                            style: ArtisanalTheme.hand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLow ? ArtisanalTheme.redInk : ArtisanalTheme.ink,
                            ),
                          ),
                          Text(
                            "/ ${item.targetQuantity.toInt()}${item.unit}",
                            style: ArtisanalTheme.hand(
                              fontSize: 10,
                              color: ArtisanalTheme.secondary.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      
                      // Urgent Marker
                      if (isLow)
                        _buildUrgentMarker(l10n),
                    ],
                  ),
                  
                  const SizedBox(height: 4), // Smaller
                  
                  // Hand-drawn like progress bar
                  _buildHandDrawnProgress(stockPercent, isLow),
                  
                  const SizedBox(height: 1), // Smaller
                  
                  // Tiny Action Indicator
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: onRestock,
                      child: Opacity(
                        opacity: 0.4,
                        child: Icon(Icons.edit_note, size: 14, color: ArtisanalTheme.ink), // Smaller
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Magnet on top
        Positioned(
          top: -4,
          left: 0,
          right: 0,
          child: Center(
            child: _buildMagnet(item.id.hashCode),
          ),
        ),
      ],
    );
  }

  Widget _buildMagnet(int seed) {
    final magnetColors = [
      const Color(0xFF455A64), // Dark Grey
      const Color(0xFFD32F2F), // Red
      const Color(0xFF1976D2), // Blue
      const Color(0xFF388E3C), // Green
    ];
    final color = magnetColors[seed % magnetColors.length];

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withValues(alpha: 0.3),
            color,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          seed % 2 == 0 ? Icons.star : Icons.cookie,
          size: 10,
          color: Colors.white.withValues(alpha: 0.5),
        ),
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
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHandDrawnProgress(double percent, bool isLow) {
    return Container(
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
                color: isLow ? ArtisanalTheme.redInk.withValues(alpha: 0.5) : ArtisanalTheme.ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // "Scribble" lines on the progress
          Positioned.fill(
            child: CustomPaint(
              painter: ScribblePainter(percent),
            ),
          ),
        ],
      ),
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
