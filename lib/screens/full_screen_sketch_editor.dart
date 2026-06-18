import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';

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
  double _currentWidth = 3.0;
  bool _isEraser = false;
  bool _isHighlighter = false;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      final paint = Paint()
        ..color = _isEraser 
            ? Colors.white 
            : (_isHighlighter ? _currentColor.withValues(alpha: 0.35) : _currentColor)
        ..strokeWidth = _currentWidth
        ..style = PaintingStyle.stroke
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
        lastPath.add(
          DrawingPoint(
            offset: details.localPosition,
            paint: lastPath.first.paint,
          ),
        );
      }
    });
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        Color selectedColor = _currentColor;
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).currentLanguage == '한국어' ? '색상 선택' : 'Choose Color',
            style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink),
          ),
          backgroundColor: const Color(0xFFF7F3F0),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HSVColorPicker(
                    initialColor: selectedColor,
                    onColorChanged: (color) {
                      setDialogState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 48,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentColor = selectedColor;
                            _isEraser = false;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppLocalizations.of(context).done,
                          style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomColorButton() {
    final standardColors = [
      ArtisanalTheme.ink,
      ArtisanalTheme.redInk,
      const Color(0xFFC27A5B),
      const Color(0xFFD4AF37),
      const Color(0xFF2E7D32),
      const Color(0xFF4A90E2),
      const Color(0xFF7B1FA2),
      const Color(0xFF000000),
    ];
    final isCustom = !standardColors.contains(_currentColor);
    return GestureDetector(
      onTap: _openColorPicker,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isCustom ? _currentColor : Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCustom ? Colors.white : Colors.white30,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.palette_outlined,
          color: isCustom ? Colors.white : Colors.white70,
          size: 14,
        ),
      ),
    );
  }

  Future<void> _saveSketch() async {
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
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
        title: Text(AppLocalizations.of(context).sketchpad.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSketch,
            child: Text(
              AppLocalizations.of(context).done.toUpperCase(),
              style: ArtisanalTheme.hand(
                color: ArtisanalTheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                    ),
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
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToolbar(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: ArtisanalTheme.ink,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Brush presets (Pen, Brush, Marker, Highlighter, Eraser) + Undo & Clear All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pen (Opaque drawing tool)
                  _buildToolButton(Icons.edit, !_isEraser && !_isHighlighter, () {
                    setState(() {
                      _isEraser = false;
                      _isHighlighter = false;
                    });
                  }, tooltip: 'Pen'),
                  const SizedBox(width: 8),
                  // Brush (Highlighter translucent tool)
                  _buildToolButton(Icons.brush, !_isEraser && _isHighlighter, () {
                    setState(() {
                      _isEraser = false;
                      _isHighlighter = true;
                    });
                  }, tooltip: 'Brush'),
                  const SizedBox(width: 10),
                  // Vertical divider to separate Tools from Sizes
                  Container(
                    width: 1,
                    height: 18,
                    color: Colors.white24,
                  ),
                  const SizedBox(width: 10),
                  // Size 1 (Small circle)
                  _buildToolButton(Icons.circle, _currentWidth == 3.0, () {
                    setState(() {
                      _currentWidth = 3.0;
                    });
                  }, tooltip: 'Size: Small', size: 5),
                  const SizedBox(width: 6),
                  // Size 2 (Medium circle)
                  _buildToolButton(Icons.circle, _currentWidth == 10.0, () {
                    setState(() {
                      _currentWidth = 10.0;
                    });
                  }, tooltip: 'Size: Medium', size: 10),
                  const SizedBox(width: 6),
                  // Size 3 (Large circle)
                  _buildToolButton(Icons.circle, _currentWidth == 20.0, () {
                    setState(() {
                      _currentWidth = 20.0;
                    });
                  }, tooltip: 'Size: Large', size: 15),
                  const SizedBox(width: 10),
                  // Eraser (Using custom vector icon matching user reference, now on the right of sizes)
                  _buildToolButtonWithWidget(
                    EraserIcon(color: _isEraser ? ArtisanalTheme.primary : Colors.white, size: 16),
                    _isEraser,
                    () {
                      setState(() {
                        _isEraser = true;
                      });
                    },
                    tooltip: 'Eraser',
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.white70, size: 16),
                    onPressed: () =>
                        setState(() => _paths.isNotEmpty ? _paths.removeLast() : null),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    tooltip: 'Undo',
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.white70, size: 16),
                    onPressed: () => setState(() => _paths.clear()),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    tooltip: 'Clear All',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          Container(height: 1, color: Colors.white12),
          const SizedBox(height: 12),
          // Row 2: Color Palette
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorButton(ArtisanalTheme.ink),
                const SizedBox(width: 10),
                _buildColorButton(ArtisanalTheme.redInk),
                const SizedBox(width: 10),
                _buildColorButton(const Color(0xFFC27A5B)),
                const SizedBox(width: 10),
                _buildColorButton(const Color(0xFFD4AF37)),
                const SizedBox(width: 10),
                _buildColorButton(const Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                _buildColorButton(const Color(0xFF4A90E2)),
                const SizedBox(width: 10),
                _buildColorButton(const Color(0xFF7B1FA2)),
                const SizedBox(width: 10),
                _buildColorButton(const Color(0xFF000000)),
                const SizedBox(width: 10),
                _buildCustomColorButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildToolButton(IconData icon, bool isSelected, VoidCallback onTap, {required String tooltip, double size = 18}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSelected ? ArtisanalTheme.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }

  Widget _buildToolButtonWithWidget(Widget child, bool isSelected, VoidCallback onTap, {required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: child,
        ),
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
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _HSVColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  const _HSVColorPicker({required this.initialColor, required this.onColorChanged});

  @override
  State<_HSVColorPicker> createState() => _HSVColorPickerState();
}

class _HSVColorPickerState extends State<_HSVColorPicker> {
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _updateColor() {
    final color = HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onPanDown: (details) {
            final x = details.localPosition.dx.clamp(0.0, 240.0);
            final y = details.localPosition.dy.clamp(0.0, 150.0);
            setState(() {
              _saturation = x / 240.0;
              _value = 1.0 - (y / 150.0);
            });
            _updateColor();
          },
          onPanUpdate: (details) {
            final x = details.localPosition.dx.clamp(0.0, 240.0);
            final y = details.localPosition.dy.clamp(0.0, 150.0);
            setState(() {
              _saturation = x / 240.0;
              _value = 1.0 - (y / 150.0);
            });
            _updateColor();
          },
          child: Container(
            width: 240,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, baseColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _saturation * 240.0 - 8,
                  top: (1.0 - _value) * 150.0 - 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 2)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 16,
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Colors.red, Colors.orange, Colors.yellow,
                Colors.green, Colors.cyan, Colors.blue,
                Colors.purple, Colors.red
              ],
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 16,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayColor: Colors.transparent,
            ),
            child: Slider(
              value: _hue,
              min: 0.0,
              max: 360.0,
              onChanged: (val) {
                setState(() {
                  _hue = val;
                });
                _updateColor();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class EraserIconPainter extends CustomPainter {
  final Color color;
  EraserIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Draw bottom surface line
    canvas.drawLine(Offset(w * 0.1, h * 0.85), Offset(w * 0.9, h * 0.85), paint);

    // Draw tilted eraser
    canvas.save();
    canvas.translate(w / 2, h / 2 - 2);
    canvas.rotate(-math.pi / 4);

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.35, height: h * 0.65),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(rect, paint);

    // Sleeve line across the eraser at 1/3 from the bottom
    final sleeveY = (h * 0.65 / 2) - (h * 0.22);
    canvas.drawLine(
      Offset(-w * 0.35 / 2, sleeveY),
      Offset(w * 0.35 / 2, sleeveY),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EraserIcon extends StatelessWidget {
  final Color color;
  final double size;
  const EraserIcon({super.key, required this.color, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: EraserIconPainter(color: color),
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
        dPath.quadraticBezierTo(
          p1.dx,
          p1.dy,
          (p1.dx + p2.dx) / 2,
          (p1.dy + p2.dy) / 2,
        );
      }

      dPath.lineTo(path.last.offset.dx, path.last.offset.dy);

      canvas.drawPath(dPath, path.first.paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SmoothPainter oldDelegate) => true;
}
