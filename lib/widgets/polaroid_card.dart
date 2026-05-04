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

    // Bottom edge
    path.lineTo(size.width - 2, size.height);

    // Right torn edge
    for (double i = size.height; i >= 0; i -= 2) {
      path.lineTo(size.width + math.cos(i * 4) * 2, i);
    }

    // Top edge
    path.lineTo(2, 0);
    path.close();

    canvas.drawPath(
      path.shift(const Offset(1, 1)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    canvas.drawPath(path, paint);

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
  final Widget? image;
  final String title;
  final String? subtitle;
  final double rotation;
  final Color? tapeColor;
  final double? width;

  const PolaroidCard({
    super.key,
    this.image,
    required this.title,
    this.subtitle,
    this.rotation = 0.0,
    this.tapeColor,
    this.width,
  });

  Widget _buildInitialPlaceholder() {
    final initial = title.isNotEmpty ? title[0].toUpperCase() : '?';
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.1,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4E342E),
                width: 1.5,
              ),
            ),
          ),
        ),
        Text(
          initial,
          style: ArtisanalTheme.hand(
            fontSize: 100,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4E342E).withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic shadow offset based on rotation
    final double shadowOffsetX = -rotation * 80;

    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: width ?? 260,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 3D Card Base with thickness, curl, and DYNAMIC SHADOW
            CustomPaint(
              size: const Size(260, 320),
              painter: _Polaroid3DPainter(shadowOffsetX: shadowOffsetX),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          // Base area for photo/placeholder
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDFCF7), // Warm off-white
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: image ?? _buildInitialPlaceholder(),
                          ),
                          // Gloss effect
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.02),
                                  ],
                                  stops: const [0.0, 0.2, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: ArtisanalTheme.note(
                        fontSize: 22,
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!.toUpperCase(),
                        style: ArtisanalTheme.lightTheme.textTheme.labelLarge
                            ?.copyWith(
                              fontSize: 10,
                              letterSpacing: 1.0,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              top: -12,
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

class _Polaroid3DPainter extends CustomPainter {
  final double shadowOffsetX;

  _Polaroid3DPainter({this.shadowOffsetX = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white;
    final thicknessPaint = Paint()..color = const Color(0xFFE0E0E0);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // 1. DYNAMIC SHADOW
    final shadowPath = Path()
      ..moveTo(5, 5)
      ..lineTo(size.width + 5, 5)
      ..lineTo(size.width + 5, size.height + 5)
      ..lineTo(5, size.height + 5)
      ..close();
    
    canvas.drawPath(shadowPath.shift(Offset(shadowOffsetX + 2, 10)), shadowPaint);

    // 2. Thickness
    final thicknessPath = Path()
      ..moveTo(2, 2)
      ..lineTo(size.width + 1.5, 2)
      ..lineTo(size.width + 1.5, size.height + 1.5)
      ..lineTo(2, size.height + 1.5)
      ..close();
    
    canvas.drawPath(thicknessPath, thicknessPaint);

    // 3. Main card with curl
    final cardPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - 10)
      ..quadraticBezierTo(
        size.width, size.height,
        size.width - 15, size.height - 2,
      )
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(cardPath, whitePaint);

    final edgePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawPath(cardPath, edgePaint);
    
    final curlShadowPath = Path()
      ..moveTo(size.width - 20, size.height - 5)
      ..quadraticBezierTo(
        size.width - 5 + (shadowOffsetX * 0.1), size.height + 2,
        size.width + 2, size.height - 8
      );
    canvas.drawPath(
      curlShadowPath, 
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
    );
  }

  @override
  bool shouldRepaint(_Polaroid3DPainter oldDelegate) => 
    oldDelegate.shadowOffsetX != shadowOffsetX;
}
