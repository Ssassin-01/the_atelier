import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';

class SketchPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  SketchPoint({required this.offset, required this.color, this.strokeWidth = 3.0});
}

class SketchPainter extends CustomPainter {
  final List<List<SketchPoint>> paths;

  SketchPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    for (var path in paths) {
      if (path.isEmpty) continue;
      
      final paint = Paint()
        ..color = path.first.color
        ..strokeWidth = path.first.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (int i = 0; i < path.length - 1; i++) {
        canvas.drawLine(path[i].offset, path[i + 1].offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) => true;
}

class SketchArea extends StatefulWidget {
  const SketchArea({super.key});

  @override
  State<SketchArea> createState() => _SketchAreaState();
}

class _SketchAreaState extends State<SketchArea> {
  final List<List<SketchPoint>> _paths = [];
  Color _currentColor = ArtisanalTheme.ink;
  final double _currentWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: ArtisanalTheme.outline.withValues(alpha: 0.2), width: 1),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.5),
            ),
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _paths.add([
                    SketchPoint(
                      offset: details.localPosition,
                      color: _currentColor,
                      strokeWidth: _currentWidth,
                    )
                  ]);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  if (_paths.isNotEmpty) {
                    _paths.last.add(SketchPoint(
                      offset: details.localPosition,
                      color: _currentColor,
                      strokeWidth: _currentWidth,
                    ));
                  }
                });
              },
              child: CustomPaint(
                painter: SketchPainter(_paths),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: ArtisanalTheme.ink,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.white70),
                onPressed: () => setState(() => _paths.isNotEmpty ? _paths.removeLast() : null),
              ),
              const VerticalDivider(color: Colors.white24, width: 24),
              _buildColorButton(ArtisanalTheme.ink),
              const SizedBox(width: 12),
              _buildColorButton(ArtisanalTheme.redInk),
              const SizedBox(width: 12),
              _buildColorButton(const Color(0xFFC27A5B)),
              const SizedBox(width: 12),
              _buildColorButton(Colors.blueGrey),
              const VerticalDivider(color: Colors.white24, width: 24),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                onPressed: () => setState(() => _paths.clear()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _currentColor == color;
    return GestureDetector(
      onTap: () => setState(() => _currentColor = color),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected) const BoxShadow(color: Colors.black26, blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
