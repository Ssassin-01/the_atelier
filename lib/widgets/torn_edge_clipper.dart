import 'package:flutter/material.dart';

class TornEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.98);

    double x = 0;
    double increment = size.width / 25;

    while (x < size.width) {
      x += increment;
      // Alternate peaks and valleys
      if ((x / increment).floor() % 2 == 0) {
        path.lineTo(x, size.height * 0.98);
      } else {
        path.lineTo(x, size.height);
      }
    }

    path.lineTo(size.width, size.height * 0.98);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TornEdgeContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const TornEdgeContainer({
    super.key,
    required this.child,
    this.color,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TornEdgeClipper(),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: child,
      ),
    );
  }
}
