import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrumpleEffect extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const CrumpleEffect({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<CrumpleEffect> createState() => _CrumpleEffectState();
}

class _CrumpleEffectState extends State<CrumpleEffect> {
  late final Animation<double> _scale;
  late final Animation<double> _rotation;
  late final Animation<double> _opacity;
  late final Animation<double> _skewX;
  late final Animation<double> _skewY;

  @override
  void initState() {
    super.initState();
    
    _scale = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: widget.controller, curve: const Interval(0.0, 0.8, curve: Curves.easeInBack)),
    );
    
    _rotation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: widget.controller, curve: const Interval(0.2, 1.0, curve: Curves.easeInOut)),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: widget.controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _skewX = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(parent: widget.controller, curve: const Interval(0.0, 0.7, curve: Curves.elasticIn)),
    );

    _skewY = Tween<double>(begin: 0.0, end: -0.1).animate(
      CurvedAnimation(parent: widget.controller, curve: const Interval(0.0, 0.7, curve: Curves.elasticIn)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        if (widget.controller.value == 0) return widget.child;

        return Opacity(
          opacity: _opacity.value,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..scale(_scale.value, _scale.value)
              ..rotateZ(_rotation.value)
              ..multiply(Matrix4.skew(_skewX.value, _skewY.value)),
            alignment: Alignment.center,
            child: Stack(
              children: [
                widget.child,
                // Wrinkle overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WrinklePainter(progress: widget.controller.value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WrinklePainter extends CustomPainter {
  final double progress;
  _WrinklePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.1) return;

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15 * progress)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final random = math.Random(42); // Seeded for consistent wrinkles

    // Draw random shadow lines (wrinkles) across the surface
    for (int i = 0; i < (20 * progress).toInt(); i++) {
      final p1 = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final p2 = Offset(p1.dx + (random.nextDouble() - 0.5) * 50 * progress, 
                        p1.dy + (random.nextDouble() - 0.5) * 50 * progress);
      
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WrinklePainter oldDelegate) => oldDelegate.progress != progress;
}
