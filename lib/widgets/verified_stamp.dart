import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';

class VerifiedStamp extends StatelessWidget {
  final double size;
  final double rotation;

  const VerifiedStamp({
    super.key,
    this.size = 80,
    this.rotation = -0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: ArtisanalTheme.redInk.withValues(alpha: 0.5),
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VERIFIED',
              style: ArtisanalTheme.hand(
                fontSize: size * 0.2,
                color: ArtisanalTheme.redInk.withValues(alpha: 0.6),
              ).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            Container(
              height: 1.5,
              width: size * 0.8,
              color: ArtisanalTheme.redInk.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 2),
            Text(
              'APPROVED LAB',
              style: ArtisanalTheme.hand(
                fontSize: size * 0.12,
                color: ArtisanalTheme.redInk.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularVerifiedStamp extends StatelessWidget {
  final double size;
  final double rotation;

  const CircularVerifiedStamp({
    super.key,
    this.size = 70,
    this.rotation = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ArtisanalTheme.redInk.withValues(alpha: 0.4),
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ArtisanalTheme.redInk.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'OK',
                  style: ArtisanalTheme.hand(
                    fontSize: size * 0.3,
                    color: ArtisanalTheme.redInk.withValues(alpha: 0.6),
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'VERIFIED',
                  style: ArtisanalTheme.hand(
                    fontSize: size * 0.14,
                    color: ArtisanalTheme.redInk.withValues(alpha: 0.5),
                  ).copyWith(letterSpacing: 1.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
