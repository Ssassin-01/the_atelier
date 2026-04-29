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
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(begin: -20.0, end: 0.0).animate(
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

    // Optimized Delay Logic:
    // 1. For initial items (0-7), use index-based stagger for a rhythmic entry.
    // 2. For items appearing during scroll (>7), use a minimal fixed jitter to feel responsive.
    Duration delay;
    if (widget.index <= 7) {
      delay = widget.delayBase * widget.index;
    } else {
      // Small random jitter for items that appear while scrolling
      delay = Duration(milliseconds: 30 + math.Random().nextInt(40));
    }

    Future.delayed(delay, () {
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
