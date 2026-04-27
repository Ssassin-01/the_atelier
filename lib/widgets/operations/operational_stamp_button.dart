import 'package:flutter/material.dart';
import '../../theme/artisanal_theme.dart';

class OperationalStampButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const OperationalStampButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<OperationalStampButton> createState() => _OperationalStampButtonState();
}

class _OperationalStampButtonState extends State<OperationalStampButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(
                        widget.icon,
                        size: 60,
                        color: widget.color.withValues(alpha: 0.03),
                      ),
                    ),
                    Icon(widget.icon, color: widget.color, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label.replaceAll('\n', ' '),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ArtisanalTheme.hand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ArtisanalTheme.ink.withValues(alpha: 0.7),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
