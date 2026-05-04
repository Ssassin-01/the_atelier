import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';

class ArtisanalImage extends StatelessWidget {
  final String? imagePath;
  final String? recipeName; // Added to generate initials
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;

  const ArtisanalImage({
    super.key,
    this.imagePath,
    this.recipeName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    final result = imagePath!.startsWith('http')
        ? Image.network(
            imagePath!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          )
        : imagePath!.startsWith('assets/')
            ? Image.asset(
                imagePath!,
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : Image.file(
                File(imagePath!),
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              );

    if (backgroundColor != null) {
      return Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: result,
      );
    }
    return result;
  }

  Widget _buildPlaceholder() {
    final initial = (recipeName != null && recipeName!.isNotEmpty)
        ? recipeName![0].toUpperCase()
        : '?';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the smaller dimension to keep the circle within bounds
        final size = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (width ?? 200.0);

        return Container(
          width: width,
          height: height,
          color: const Color(0xFFFDFCF7),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Faint Ornate Seal Border
              Opacity(
                opacity: 0.1,
                child: Container(
                  width: size * 0.7,
                  height: size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF4E342E), width: 1.5),
                  ),
                ),
              ),
              // The Initial
              Text(
                initial,
                style: ArtisanalTheme.hand(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4E342E).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
