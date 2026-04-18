import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/artisanal_theme.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

class FullScreenSketchEditor extends StatefulWidget {
  final String? initialImagePath;
  const FullScreenSketchEditor({super.key, this.initialImagePath});

  @override
  State<FullScreenSketchEditor> createState() => _FullScreenSketchEditorState();
}

class _FullScreenSketchEditorState extends State<FullScreenSketchEditor> {
  final List<List<DrawingPoint>> _paths = [];
  final GlobalKey _canvasKey = GlobalKey();
  
  Color _currentColor = ArtisanalTheme.ink;
  double _currentWidth = 2.0;
  bool _isEraser = false;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      final paint = Paint()
        ..color = _isEraser ? Colors.white : _currentColor
        ..strokeWidth = _currentWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..blendMode = _isEraser ? BlendMode.clear : BlendMode.srcOver;
        
      _paths.add([DrawingPoint(offset: details.localPosition, paint: paint)]);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      if (_paths.isNotEmpty) {
        final lastPath = _paths.last;
        lastPath.add(DrawingPoint(offset: details.localPosition, paint: lastPath.first.paint));
      }
    });
  }

  Future<void> _saveSketch() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'sketch_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      debugPrint("Error saving sketch: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: AppBar(
        title: Text("SKETCHPAD", style: ArtisanalTheme.hand(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSketch,
            child: Text("DONE", style: ArtisanalTheme.hand(color: ArtisanalTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      child: CustomPaint(
                        painter: SmoothPainter(_paths),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildToolbar(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: ArtisanalTheme.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolButton(Icons.edit, !_isEraser && _currentWidth < 4, () {
            setState(() {
              _isEraser = false;
              _currentWidth = 2.0;
            });
          }),
          const SizedBox(width: 12),
          _buildToolButton(Icons.brush, !_isEraser && _currentWidth >= 4, () {
            setState(() {
              _isEraser = false;
              _currentWidth = 8.0;
            });
          }),
          const SizedBox(width: 12),
          _buildToolButton(Icons.auto_fix_normal, _isEraser, () {
            setState(() {
              _isEraser = true;
              _currentWidth = 20.0;
            });
          }),
          const VerticalDivider(color: Colors.white24, width: 32),
          _buildColorButton(ArtisanalTheme.ink),
          const SizedBox(width: 8),
          _buildColorButton(ArtisanalTheme.redInk),
          const SizedBox(width: 8),
          _buildColorButton(const Color(0xFFC27A5B)),
          const VerticalDivider(color: Colors.white24, width: 32),
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white70),
            onPressed: () => setState(() => _paths.isNotEmpty ? _paths.removeLast() : null),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? ArtisanalTheme.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = !_isEraser && _currentColor == color;
    return GestureDetector(
      onTap: () => setState(() {
        _currentColor = color;
        _isEraser = false;
      }),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
        ),
      ),
    );
  }
}

class SmoothPainter extends CustomPainter {
  final List<List<DrawingPoint>> paths;
  SmoothPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
    for (var path in paths) {
      if (path.isEmpty) continue;
      
      final dPath = Path();
      dPath.moveTo(path.first.offset.dx, path.first.offset.dy);
      
      for (int i = 0; i < path.length - 1; i++) {
        final p1 = path[i].offset;
        final p2 = path[i + 1].offset;
        // Using quadratic bezier for smoothness
        dPath.quadraticBezierTo(
          p1.dx,
          p1.dy,
          (p1.dx + p2.dx) / 2,
          (p1.dy + p2.dy) / 2,
        );
      }
      
      // Add the last point
      dPath.lineTo(path.last.offset.dx, path.last.offset.dy);
      
      canvas.drawPath(dPath, path.first.paint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SmoothPainter oldDelegate) => true;
}
