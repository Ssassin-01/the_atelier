import 'package:flutter/material.dart';

class MaskingTape extends StatelessWidget {
  final String? label;
  final double width;
  final Color color;
  final double rotation;

  const MaskingTape({
    super.key,
    this.label,
    this.width = 120,
    this.color = const Color(0xFFE2DCC8),
    this.rotation = -0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: ClipPath(
          clipper: _TapeEdgeClipper(),
          child: Container(
            color: color.withValues(alpha: 0.3),
            alignment: Alignment.center,
            child: label != null
                ? Text(
                    label!.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Courier', // Standard typewriter feel
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withValues(alpha: 0.4),
                      letterSpacing: 1.5,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _TapeEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    
    // Zigzag left edge
    double x = 0;
    while (x < size.height) {
      path.lineTo(2, x + 2);
      path.lineTo(0, x + 4);
      x += 4;
    }
    
    path.lineTo(size.width, size.height);
    
    // Zigzag right edge
    x = size.height;
    while (x > 0) {
      path.lineTo(size.width - 2, x - 2);
      path.lineTo(size.width, x - 4);
      x -= 4;
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
