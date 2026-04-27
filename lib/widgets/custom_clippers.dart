import 'package:flutter/material.dart';

class SerratedClipper extends CustomClipper<Path> {
  final double toothWidth;
  final double toothHeight;
  final bool top;
  final bool bottom;

  SerratedClipper({
    this.toothWidth = 20,
    this.toothHeight = 10,
    this.top = true,
    this.bottom = true,
  });



  @override
  Path getClip(Size size) {
    var path = Path();
    
    // Start at top-left (with teeth if top is true)
    if (top) {
      path.moveTo(0, toothHeight);
      for (double x = 0; x <= size.width; x += toothWidth) {
        path.lineTo(x + toothWidth / 2, 0);
        path.lineTo(x + toothWidth, toothHeight);
      }
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
    }

    // Right side
    path.lineTo(size.width, size.height - (bottom ? toothHeight : 0));

    // Bottom side (teeth)
    if (bottom) {
      for (double x = size.width; x >= 0; x -= toothWidth) {
        path.lineTo(x - toothWidth / 2, size.height);
        path.lineTo(x - toothWidth, size.height - toothHeight);
      }
    } else {
      path.lineTo(0, size.height);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ScallopedClipper extends CustomClipper<Path> {
  final double radius;
  final bool bottom;

  ScallopedClipper({this.radius = 12, this.bottom = true});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    
    if (bottom) {
      path.lineTo(size.width, size.height - radius);
      for (double x = size.width; x >= 0; x -= radius * 2) {
        path.relativeArcToPoint(
          Offset(-radius * 2, 0),
          radius: Radius.circular(radius),
          clockwise: false,
        );
      }
      path.lineTo(0, size.height - radius);
    } else {
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TornPaperClipper extends CustomClipper<Path> {
  final double intensity;
  final int seed;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  TornPaperClipper({
    this.intensity = 2.0, 
    this.seed = 0,
    this.top = true, 
    this.bottom = true, 
    this.left = false, 
    this.right = false
  });

  @override
  Path getClip(Size size) {
    var path = Path();
    
    // Starting point
    double startY = top ? intensity : 0;
    path.moveTo(0, startY);

    // Top Edge
    if (top) {
      for (double x = 0; x <= size.width; x += 6) {
        path.lineTo(x, ((x + seed).toInt() % 12 < 6) ? 0 : intensity);
      }
    } else {
      path.lineTo(size.width, 0);
    }

    // Right Edge
    if (right) {
      for (double y = 0; y <= size.height; y += 6) {
         path.lineTo(size.width - (((y + seed).toInt() % 12 < 6) ? 0 : intensity), y);
      }
    } else {
      path.lineTo(size.width, size.height);
    }

    // Bottom Edge
    if (bottom) {
      for (double x = size.width; x >= 0; x -= 6) {
        path.lineTo(x, size.height - (((x + seed).toInt() % 12 < 6) ? 0 : intensity));
      }
    } else {
      path.lineTo(0, size.height);
    }

    // Left Edge
    if (left) {
      for (double y = size.height; y >= 0; y -= 6) {
        path.lineTo(((y + seed).toInt() % 12 < 6) ? 0 : intensity, y);
      }
    } else {
      path.lineTo(0, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
