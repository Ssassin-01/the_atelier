import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_clippers.dart';

class ShoppingItem {
  final String id;
  final String name;
  double quantity;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1.0,
  });
}

class PantryShoppingScreen extends ConsumerStatefulWidget {
  const PantryShoppingScreen({super.key});

  @override
  ConsumerState<PantryShoppingScreen> createState() => _PantryShoppingScreenState();
}

class _PantryShoppingScreenState extends ConsumerState<PantryShoppingScreen> with TickerProviderStateMixin {
  final List<ShoppingItem> _toBuyList = [];
  final List<ShoppingItem> _purchasedList = [];
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isAdding = false;
  bool _showCartDetails = false;
  
  late AnimationController _cartBounceController;
  late Animation<double> _cartBounce;
  late AnimationController _windController;

  @override
  void initState() {
    super.initState();
    _cartBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cartBounce = CurvedAnimation(parent: _cartBounceController, curve: Curves.elasticOut);

    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  void _addItem() {
    if (_inputController.text.trim().isEmpty) {
      setState(() => _isAdding = false);
      return;
    }
    
    HapticFeedback.mediumImpact();
    setState(() {
      _toBuyList.add(ShoppingItem(
        id: DateTime.now().toString(),
        name: _inputController.text.trim(),
      ));
      _inputController.clear();
      _isAdding = false;
    });
  }

  void _moveToCart(String id) {
    _cartBounceController.forward(from: 0.0);
    HapticFeedback.mediumImpact();
    setState(() {
      final itemIndex = _toBuyList.indexWhere((item) => item.id == id);
      if (itemIndex != -1) {
        _purchasedList.add(_toBuyList.removeAt(itemIndex));
      }
    });
  }

  void _updateQuantity(int index, double delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _toBuyList[index].quantity = (_toBuyList[index].quantity + delta).clamp(0.5, 99.0);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _cartBounceController.dispose();
    _windController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.12,
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 80,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    l10n.currentLanguage == '한국어' ? '식재료 전표' : 'ORDER SHEET',
                    style: ArtisanalTheme.hand(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: ArtisanalTheme.ink,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 45, 20),
                    child: _buildTrue3DMemoBlock(context, l10n),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 150, top: 40),
                    child: _buildFinal3DCart(context),
                  ),
                ),
              ],
            ),
            
            if (_showCartDetails) _buildCartDetailsPanel(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTrue3DMemoBlock(BuildContext context, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _windController,
      builder: (context, child) {
        return CustomPaint(
          painter: True3DMemoBlockPainter(windValue: _windController.value),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 50, 40, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MARKET JOURNAL', style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black12)),
                      _build3DPushPin(),
                    ],
                  ),
                  const Divider(height: 50, color: Colors.black12),
                  ..._toBuyList.asMap().entries.map((entry) => _buildShoppingRow(entry.key, entry.value)).toList(),
                  if (_isAdding) _buildInputRow(l10n) else _buildAddTrigger(l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _build3DPushPin() {
    return Container(
      width: 30,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 15,
            left: 15,
            child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), shape: BoxShape.circle)),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.redAccent, Colors.red.shade900],
                center: const Alignment(-0.3, -0.3),
              ),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(2, 2))],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingRow(int index, ShoppingItem item) {
    return LongPressDraggable<String>(
      data: item.id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
            border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.1)),
          ),
          child: Text(item.name, style: ArtisanalTheme.hand(fontSize: 22)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.1, child: _rowContent(index, item)),
      child: _rowContent(index, item),
    );
  }

  Widget _rowContent(int index, ShoppingItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))),
      child: Row(
        children: [
          Expanded(child: Text(item.name, style: ArtisanalTheme.hand(fontSize: 24, color: ArtisanalTheme.ink))),
          _buildQtyControls(index, item),
        ],
      ),
    );
  }

  Widget _buildQtyControls(int index, ShoppingItem item) {
    return Row(
      children: [
        _qtyBtn(Icons.remove, () => _updateQuantity(index, -1)),
        SizedBox(
          width: 45,
          child: Text(item.quantity.toStringAsFixed(0), textAlign: TextAlign.center, style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.primary)),
        ),
        _qtyBtn(Icons.add, () => _updateQuantity(index, 1)),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: ArtisanalTheme.ink.withValues(alpha: 0.4)),
      ),
    );
  }

  Widget _buildFinal3DCart(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => _moveToCart(details.data),
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        
        return GestureDetector(
          onTap: () => setState(() => _showCartDetails = !_showCartDetails),
          child: AnimatedBuilder(
            animation: _cartBounce,
            builder: (context, child) {
              return Center(
                child: Transform.scale(
                  scale: isHovering ? 1.05 : 1.0 + (_cartBounce.value * 0.05),
                  child: Container(
                    height: 300,
                    width: 350,
                    child: CustomPaint(
                      painter: Final3DCartPainter(
                        isHovering: isHovering,
                        itemCount: _purchasedList.length,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInputRow(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        controller: _inputController,
        focusNode: _focusNode,
        autofocus: true,
        style: ArtisanalTheme.hand(fontSize: 24),
        decoration: InputDecoration(
          hintText: l10n.currentLanguage == '한국어' ? '재료 추가...' : 'Add item...',
          border: InputBorder.none,
          icon: const Icon(Icons.edit, size: 24, color: ArtisanalTheme.primary),
        ),
        onSubmitted: (_) => _addItem(),
      ),
    );
  }

  Widget _buildAddTrigger(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => setState(() => _isAdding = true),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.black12, size: 28),
            const SizedBox(width: 15),
            Text(l10n.currentLanguage == '한국어' ? '다음 항목...' : 'Next...', style: ArtisanalTheme.hand(fontSize: 24, color: Colors.black12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartDetailsPanel(AppLocalizations l10n) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showCartDetails = false),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 480,
              width: double.infinity,
              decoration: const BoxDecoration(color: Color(0xFFFDFCF7), borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 30),
                  Text(l10n.currentLanguage == '한국어' ? '카트 내용물' : 'BASKET CONTENT', style: ArtisanalTheme.hand(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Divider(height: 40),
                  Expanded(
                    child: _purchasedList.isEmpty
                        ? Center(child: Text('텅 비어있음', style: ArtisanalTheme.hand(color: Colors.black26)))
                        : ListView.builder(
                            itemCount: _purchasedList.length,
                            itemBuilder: (context, index) {
                              final item = _purchasedList[index];
                              return ListTile(
                                leading: const Icon(Icons.shopping_basket, color: ArtisanalTheme.primary),
                                title: Text(item.name, style: ArtisanalTheme.hand(fontSize: 22)),
                                trailing: Text('x${item.quantity.toStringAsFixed(0)}', style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.primary)),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class True3DMemoBlockPainter extends CustomPainter {
  final double windValue;
  True3DMemoBlockPainter({required this.windValue});

  @override
  void paint(Canvas canvas, Size size) {
    double thickness = 14.0; // Thick stack
    final blockColor = const Color(0xFFF2EEE2);
    final blockDark = const Color(0xFFDCD4C4);
    
    // 1. Shadow for the entire block
    Path shadow = Path()
      ..moveTo(thickness, thickness)
      ..lineTo(size.width + thickness, thickness)
      ..lineTo(size.width + thickness + 5, size.height + thickness + 10)
      ..lineTo(thickness - 5, size.height + thickness + 10)
      ..close();
    canvas.drawPath(shadow, Paint()..color = Colors.black.withValues(alpha: 0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25));

    // 2. Right Face (Thickness)
    Path rightFace = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width + thickness, thickness)
      ..lineTo(size.width + thickness, size.height + thickness)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = blockDark);

    // 3. Bottom Face (Thickness)
    Path bottomFace = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width + thickness, size.height + thickness)
      ..lineTo(thickness, size.height + thickness)
      ..close();
    canvas.drawPath(bottomFace, Paint()..color = blockDark);

    // 4. Page Lines Texture on Thickness
    final linePaint = Paint()..color = Colors.black.withValues(alpha: 0.08)..strokeWidth = 0.5;
    for (int i = 2; i < thickness; i += 3) {
      // Horizontal lines on bottom face
      canvas.drawLine(Offset(i.toDouble(), size.height + i), Offset(size.width + i, size.height + i), linePaint);
      // Vertical-ish lines on right face
      canvas.drawLine(Offset(size.width + i, i.toDouble()), Offset(size.width + i, size.height + i), linePaint);
    }

    // 5. The Top Sheet (Animated)
    double wave = math.sin(windValue * math.pi * 2) * 8;
    final topSheetPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEFDF9), Color(0xFFF2EEE2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    double foldSize = 45.0;
    Path topSheet = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - foldSize + (wave * 0.4))
      ..lineTo(size.width - foldSize, size.height + wave)
      ..lineTo(0, size.height + wave)
      ..close();

    // Subtle contact shadow between top sheet and block
    canvas.drawPath(topSheet.shift(const Offset(0, 2)), Paint()..color = Colors.black12..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(topSheet, topSheetPaint);

    // 6. Realistic Fold (Flipped corner)
    final foldPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFD0C8B8), const Color(0xFFFDFCF7)],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(size.width - foldSize, size.height - foldSize, foldSize, foldSize));
    
    Path foldPath = Path()
      ..moveTo(size.width, size.height - foldSize + (wave * 0.4))
      ..lineTo(size.width - foldSize, size.height + wave)
      ..lineTo(size.width - foldSize * 0.15, size.height + wave - foldSize * 0.15)
      ..close();
    
    canvas.drawPath(foldPath.shift(const Offset(1, 1)), Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(foldPath, foldPaint);
  }

  @override
  bool shouldRepaint(covariant True3DMemoBlockPainter oldDelegate) => oldDelegate.windValue != windValue;
}

class Final3DCartPainter extends CustomPainter {
  final bool isHovering;
  final int itemCount;

  Final3DCartPainter({required this.isHovering, required this.itemCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    double depth = 70;
    Offset b1 = center + const Offset(-60, 10); 
    Offset b2 = center + const Offset(60, 10);
    Offset b3 = center + const Offset(80, 50);
    Offset b4 = center + const Offset(-40, 50);
    Offset t1 = b1 + Offset(-40, -depth);
    Offset t2 = b2 + Offset(40, -depth);
    Offset t3 = b3 + Offset(50, -depth);
    Offset t4 = b4 + Offset(-30, -depth);

    final Color metalBase = isHovering ? ArtisanalTheme.primary : const Color(0xFF333333);
    final Color metalLight = isHovering ? ArtisanalTheme.primary.withValues(alpha: 0.6) : const Color(0xFF777777);

    Path shadow = Path()..moveTo(b1.dx, b1.dy)..lineTo(b2.dx, b2.dy)..lineTo(b3.dx, b3.dy)..lineTo(b4.dx, b4.dy)..close();
    canvas.drawPath(shadow, Paint()..color = Colors.black.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));

    _draw3DWheel(canvas, b1, 14, metalBase);
    _draw3DWheel(canvas, b2, 14, metalBase);
    _drawHandle(canvas, t1, -1, metalBase, metalLight);
    _drawThickWall(canvas, t1, t2, b2, b1, metalBase, metalLight, divisions: 5);
    _drawThickWall(canvas, t1, t4, b4, b1, metalBase, metalLight, divisions: 4);
    _drawThickWall(canvas, b1, b2, b3, b4, metalBase, metalLight, divisions: 5);

    if (itemCount > 0) {
      final itemPaint = Paint()..color = ArtisanalTheme.primary.withValues(alpha: 0.3);
      final rand = math.Random(1);
      for(int i=0; i<math.min(itemCount, 8); i++) {
        canvas.drawCircle(b1 + Offset(25 + rand.nextDouble()*60, 15 + rand.nextDouble()*20), 10, itemPaint);
      }
    }

    _drawThickWall(canvas, t2, t3, b3, b2, metalBase, metalLight, divisions: 4);
    _drawThickWall(canvas, t4, t3, b3, b4, metalBase, metalLight, divisions: 5);
    _drawHandle(canvas, t4, -1, metalBase, metalLight);
    _draw3DWheel(canvas, b3, 12, metalBase);
    _draw3DWheel(canvas, b4, 12, metalBase);

    _drawTubeLine(canvas, t1, t2, 7.0, metalBase, metalLight);
    _drawTubeLine(canvas, t2, t3, 7.0, metalBase, metalLight);
    _drawTubeLine(canvas, t3, t4, 7.0, metalBase, metalLight);
    _drawTubeLine(canvas, t4, t1, 7.0, metalBase, metalLight);
  }

  void _drawThickWall(Canvas canvas, Offset p1, Offset p2, Offset p3, Offset p4, Color base, Color light, {int divisions = 4}) {
    for (int i = 0; i <= divisions; i++) {
      double t = i / divisions;
      Offset vStart = Offset(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
      Offset vEnd = Offset(p4.dx + (p3.dx - p4.dx) * t, p4.dy + (p3.dy - p4.dy) * t);
      _drawTubeLine(canvas, vStart, vEnd, 3.0, base, light);
      Offset hStart = Offset(p1.dx + (p4.dx - p1.dx) * t, p1.dy + (p4.dy - p1.dy) * t);
      Offset hEnd = Offset(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
      _drawTubeLine(canvas, hStart, hEnd, 3.0, base, light);
    }
  }

  void _drawTubeLine(Canvas canvas, Offset p1, Offset p2, double width, Color base, Color light) {
    canvas.drawLine(p1, p2, Paint()..color = base..strokeWidth = width..strokeCap = StrokeCap.round);
    canvas.drawLine(p1 + const Offset(1, -1), p2 + const Offset(1, -1), Paint()..color = light..strokeWidth = width * 0.3..strokeCap = StrokeCap.round);
  }

  void _drawHandle(Canvas canvas, Offset pos, double direction, Color base, Color light) {
    Offset h1 = pos + Offset(direction * 40, -10);
    Offset h2 = h1 + Offset(direction * 20, -30);
    _drawTubeLine(canvas, pos, h1, 6.0, base, light);
    _drawTubeLine(canvas, h1, h2, 6.0, base, light);
    canvas.drawCircle(h2, 8, Paint()..color = ArtisanalTheme.ink);
  }

  void _draw3DWheel(Canvas canvas, Offset pos, double radius, Color base) {
    canvas.drawLine(pos, pos + const Offset(0, 15), Paint()..color = base..strokeWidth = 5);
    Offset wheelPos = pos + const Offset(0, 20);
    canvas.drawCircle(wheelPos, radius, Paint()..color = Colors.black);
    canvas.drawCircle(wheelPos, radius * 0.7, Paint()..color = Colors.grey.shade700..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(wheelPos, 3, Paint()..color = Colors.grey);
  }

  @override
  bool shouldRepaint(covariant Final3DCartPainter oldDelegate) => 
      oldDelegate.isHovering != isHovering || oldDelegate.itemCount != itemCount;
}
