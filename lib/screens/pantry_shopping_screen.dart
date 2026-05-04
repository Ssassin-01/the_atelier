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

  @override
  void initState() {
    super.initState();
    _cartBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cartBounce = CurvedAnimation(parent: _cartBounceController, curve: Curves.elasticOut);
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: _buildArtisanal3DParchment(context, l10n),
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

  Widget _buildArtisanal3DParchment(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: ClipPath(
        clipper: ZigZagClipper(),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 450),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFEFDF9), Color(0xFFF2EEE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MARKET LIST', style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black38)),
                    const Icon(Icons.push_pin, color: Colors.redAccent, size: 26),
                  ],
                ),
                const Divider(height: 50, color: Colors.black12),
                ..._toBuyList.asMap().entries.map((entry) => _buildShoppingRow(entry.key, entry.value)).toList(),
                if (_isAdding) _buildInputRow(l10n) else _buildAddTrigger(l10n),
              ],
            ),
          ),
        ),
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
            borderRadius: BorderRadius.circular(4),
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

class Final3DCartPainter extends CustomPainter {
  final bool isHovering;
  final int itemCount;

  Final3DCartPainter({required this.isHovering, required this.itemCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    
    // Geometry Data
    double depth = 70;
    
    // Bottom (Floor)
    Offset b1 = center + const Offset(-60, 10); 
    Offset b2 = center + const Offset(60, 10);
    Offset b3 = center + const Offset(80, 50);
    Offset b4 = center + const Offset(-40, 50);

    // Top (Rim)
    Offset t1 = b1 + Offset(-40, -depth);
    Offset t2 = b2 + Offset(40, -depth);
    Offset t3 = b3 + Offset(50, -depth);
    Offset t4 = b4 + Offset(-30, -depth);

    final Color metalBase = isHovering ? ArtisanalTheme.primary : const Color(0xFF333333);
    final Color metalLight = isHovering ? ArtisanalTheme.primary.withValues(alpha: 0.6) : const Color(0xFF777777);

    // 1. Shadow
    Path shadow = Path()..moveTo(b1.dx, b1.dy)..lineTo(b2.dx, b2.dy)..lineTo(b3.dx, b3.dy)..lineTo(b4.dx, b4.dy)..close();
    canvas.drawPath(shadow, Paint()..color = Colors.black.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));

    // 2. Far-side Wheels (Rendered behind)
    _draw3DWheel(canvas, b1, 14, metalBase);
    _draw3DWheel(canvas, b2, 14, metalBase);

    // 3. Far-side Handle (t1) - Rendered behind the walls
    _drawHandle(canvas, t1, -1, metalBase, metalLight);

    // 4. Far-side Walls
    _drawThickWall(canvas, t1, t2, b2, b1, metalBase, metalLight, divisions: 5); // Back
    _drawThickWall(canvas, t1, t4, b4, b1, metalBase, metalLight, divisions: 4); // Left

    // 5. Bottom
    _drawThickWall(canvas, b1, b2, b3, b4, metalBase, metalLight, divisions: 5);

    // 6. Items
    if (itemCount > 0) {
      final itemPaint = Paint()..color = ArtisanalTheme.primary.withValues(alpha: 0.3);
      final rand = math.Random(1);
      for(int i=0; i<math.min(itemCount, 8); i++) {
        canvas.drawCircle(b1 + Offset(25 + rand.nextDouble()*60, 15 + rand.nextDouble()*20), 10, itemPaint);
      }
    }

    // 7. Near-side Walls
    _drawThickWall(canvas, t2, t3, b3, b2, metalBase, metalLight, divisions: 4); // Right
    _drawThickWall(canvas, t4, t3, b3, b4, metalBase, metalLight, divisions: 5); // Front

    // 8. Near-side Handle (t4) - Rendered AT THE FRONT (on top of walls)
    _drawHandle(canvas, t4, -1, metalBase, metalLight);

    // 9. Near-side Wheels (Rendered in front)
    _draw3DWheel(canvas, b3, 12, metalBase);
    _draw3DWheel(canvas, b4, 12, metalBase);

    // 10. Top Rim (Rendered last for crispness)
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
