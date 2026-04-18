import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';

class ArtisanalImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ArtisanalImage({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildError();
    }

    if (imagePath!.startsWith('http')) {
      return Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    } else if (imagePath!.startsWith('assets/')) {
      return Image.asset(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    } else {
      return Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    }
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      color: ArtisanalTheme.background,
      child: const Icon(Icons.broken_image, color: ArtisanalTheme.outline),
    );
  }
}
