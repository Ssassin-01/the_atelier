import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';

class WashiTape extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final double opacity;
  final double rotation;

  const WashiTape({
    super.key,
    this.width = 90,
    this.height = 24,
    this.color,
    this.opacity = 0.6,
    this.rotation = 0.012,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _WashiPainter(color ?? const Color(0xFF8D6E63)),
          ),
        ),
      ),
    );
  }
}

class _WashiPainter extends CustomPainter {
  final Color color;
  _WashiPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Left torn edge
    path.moveTo(math.sin(0) * 2, 0);
    for (double i = 0; i <= size.height; i += 2) {
      path.lineTo(math.sin(i * 5) * 2 - 1, i);
    }

    // Bottom edge (mostly straight but slightly organic)
    path.lineTo(size.width - 2, size.height);

    // Right torn edge
    for (double i = size.height; i >= 0; i -= 2) {
      path.lineTo(size.width + math.cos(i * 4) * 2, i);
    }

    // Top edge
    path.lineTo(2, 0);
    path.close();

    // Draw shadow first
    canvas.drawPath(
      path.shift(const Offset(1, 1)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    canvas.drawPath(path, paint);

    // Add some fiber texture/lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;
    
    for (double i = 4; i < size.width; i += 8) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PolaroidCard extends StatelessWidget {
  final Widget image;
  final String title;
  final String? subtitle;
  final double rotation;
  final Color? tapeColor;
  final double? width;

  const PolaroidCard({
    super.key,
    required this.image,
    required this.title,
    this.subtitle,
    this.rotation = 0.0,
    this.tapeColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width ?? 250,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 28), // Reduced from 40 to prevent overflow
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: const Color(0xFFF5F5F3),
                    child: image,
                  ),
                ),
                const SizedBox(height: 12), // Reduced from 16
                Text(
                  title,
                  style: ArtisanalTheme.note(fontSize: 22, color: Colors.black87), // Slightly smaller font
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2), // Reduced from 4
                  Text(
                    subtitle!.toUpperCase(),
                    style: ArtisanalTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      fontSize: 10,
                      letterSpacing: -0.5,
                      color: Colors.black38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            Positioned(
              top: -24,
              left: 0,
              right: 0,
              child: Center(
                child: WashiTape(color: tapeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
