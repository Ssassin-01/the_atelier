import 'package:flutter/material.dart';
import 'dart:math' as math;

class StaggeredDropAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayBase;

  const StaggeredDropAnimation({
    super.key,
    required this.child,
    required this.index,
    this.delayBase = const Duration(milliseconds: 50),
  });

  @override
  State<StaggeredDropAnimation> createState() => _StaggeredDropAnimationState();
}

class _StaggeredDropAnimationState extends State<StaggeredDropAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _rotationAnimation = Tween<double>(begin: 0.05, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    final randomJitter = Duration(milliseconds: math.Random().nextInt(40));
    final calculatedDelay = widget.delayBase * (widget.index % 10); // Use modulo to keep stagger tight
    Future.delayed(calculatedDelay + randomJitter, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
