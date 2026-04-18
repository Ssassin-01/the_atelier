import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';

class WashiTape extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final double opacity;
  final double rotation;

  const WashiTape({
    super.key,
    this.width = 80,
    this.height = 25,
    this.color,
    this.opacity = 0.4,
    this.rotation = -0.035, // Approx -2 degrees in radians
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: (color ?? ArtisanalTheme.outline).withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
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
                const SizedBox(height: 16),
                Text(
                  title,
                  style: ArtisanalTheme.note(fontSize: 24, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
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
