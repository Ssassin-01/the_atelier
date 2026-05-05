import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class ShoppingItem {
  final String id;
  String name;
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
  final ScrollController _scrollController = ScrollController();
  
  String? _editingId;
  final TextEditingController _editController = TextEditingController();

  bool _isAdding = false;
  
  late AnimationController _windController;

  // Item Flying Animation
  late AnimationController _flyingController;
  late Animation<double> _flyingProgress;
  Offset _flyingStart = Offset.zero;
  String? _flyingItemName;

  // GlobalKey to find the "Purchased" section position
  final GlobalKey _purchasedSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _windController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _flyingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flyingProgress = CurvedAnimation(parent: _flyingController, curve: Curves.easeInOutCubic);
  }

  void _addItem() {
    if (_editingId != null) _finishEditing(); // Auto-finish previous edit
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

  Future<void> _startTossSequence(String id, String name, double qty, BuildContext itemContext) async {
    if (_editingId != null) _finishEditing(); // Auto-finish edit before toss
    final RenderBox itemBox = itemContext.findRenderObject() as RenderBox;
    final startPos = itemBox.localToGlobal(Offset.zero);
    
    setState(() {
      _flyingStart = startPos;
      _flyingItemName = name;
      final itemIndex = _toBuyList.indexWhere((item) => item.id == id);
      if (itemIndex != -1) {
        _toBuyList.removeAt(itemIndex);
      }
    });

    HapticFeedback.lightImpact();
    await _flyingController.forward(from: 0.0);
    HapticFeedback.heavyImpact();
    
    setState(() {
      _purchasedList.add(ShoppingItem(id: id, name: name, quantity: qty));
      _flyingItemName = null;
    });
  }

  void _undoPurchase(ShoppingItem item) {
    HapticFeedback.selectionClick();
    setState(() {
      _purchasedList.removeWhere((it) => it.id == item.id);
      _toBuyList.add(item);
    });
  }

  void _updateQuantity(int index, double delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _toBuyList[index].quantity = (_toBuyList[index].quantity + delta).clamp(0.5, 99.0);
    });
  }

  void _startEditing(ShoppingItem item) {
    if (_editingId != null && _editingId != item.id) _finishEditing(); // Save previous
    setState(() {
      _editingId = item.id;
      _editController.text = item.name;
    });
  }

  void _finishEditing() {
    if (_editingId == null) return;
    setState(() {
      final index = _toBuyList.indexWhere((it) => it.id == _editingId);
      if (index != -1) {
        _toBuyList[index].name = _editController.text.trim();
      }
      _editingId = null;
    });
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _editController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _windController.dispose();
    _flyingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: GestureDetector(
        onTap: () {
          if (_editingId != null) _finishEditing();
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Fixed Wallpaper Background
            if (ref.watch(settingsProvider).appMode != 'basic')
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/wallpaper.png'),
                      repeat: ImageRepeat.repeat,
                      opacity: 0.12,
                    ),
                  ),
                ),
              ),
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 80,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    l10n.currentLanguage == '한국어' ? '식재료 공정' : 'PANTRY PROCESS',
                    style: ArtisanalTheme.hand(fontSize: 28, fontWeight: FontWeight.bold, color: ArtisanalTheme.ink),
                  ),
                ),
                
                // SECTION 1: TO BUY
                _buildSectionHeader(l10n.currentLanguage == '한국어' ? '계획' : 'PLANNING'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 10, 45, 40),
                    child: _buildNatural3DMemoPad(context, l10n),
                  ),
                ),

                // SECTION 2: PURCHASED (FULFILLMENT)
                _buildSectionHeader(l10n.currentLanguage == '한국어' ? '담은 제품' : 'COLLECTED', sectionKey: _purchasedSectionKey),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 10, 45, 100),
                    child: _buildPurchasedParchment(context, l10n),
                  ),
                ),
              ],
            ),
            
            if (_flyingItemName != null) _buildFlyingItemOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Key? sectionKey}) {
    return SliverToBoxAdapter(
      child: Padding(
        key: sectionKey,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Text(
          title,
          style: ArtisanalTheme.hand(fontSize: 16, fontWeight: FontWeight.bold, color: ArtisanalTheme.primary.withValues(alpha: 0.6), letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _buildFlyingItemOverlay() {
    return AnimatedBuilder(
      animation: _flyingProgress,
      builder: (context, child) {
        double t = _flyingProgress.value;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Try to fly towards the "Collected" section or simply downwards
        Offset endPos = Offset(screenWidth / 2 - 50, screenHeight - 200);
        
        // If we can find the section, aim for it
        if (_purchasedSectionKey.currentContext != null) {
          final renderObject = _purchasedSectionKey.currentContext!.findRenderObject();
          if (renderObject is RenderBox) {
            final pos = renderObject.localToGlobal(Offset.zero);
            // If the section is on screen, aim for its center
            if (pos.dy > 0 && pos.dy < screenHeight) {
              endPos = Offset(pos.dx + 50, pos.dy + 50);
            }
          }
        }
        
        double x = _flyingStart.dx + (endPos.dx - _flyingStart.dx) * t;
        double y = _flyingStart.dy + (endPos.dy - _flyingStart.dy) * t;
        double arc = math.sin(t * math.pi) * 150;
        y -= arc;

        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: 1.0 - (t * 0.4),
            child: Transform.rotate(
              angle: t * math.pi * 0.5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Text(_flyingItemName!, style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNatural3DMemoPad(BuildContext context, AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _windController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 60, offset: const Offset(5, 30))]),
          child: CustomPaint(
            painter: MemoPad3DPainter(windValue: _windController.value),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('ORDER SHEET', style: ArtisanalTheme.hand(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black12))),
                        _build3DPushPin(),
                      ],
                    ),
                    const Divider(height: 40, color: Colors.black12),
                    ..._toBuyList.asMap().entries.map((entry) => _buildShoppingRow(entry.key, entry.value)).toList(),
                    if (_isAdding) _buildInputRow(l10n) else _buildAddTrigger(l10n),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPurchasedParchment(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(3, 15))]),
      child: CustomPaint(
        painter: Simple3DParchmentPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('COLLECTED RECORD', style: ArtisanalTheme.hand(fontSize: 18, color: Colors.black12, letterSpacing: 2)),
              const SizedBox(height: 20),
              if (_purchasedList.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(l10n.currentLanguage == '한국어' ? '아직 담은 제품이 없습니다' : 'Nothing collected yet', style: ArtisanalTheme.hand(color: Colors.black12, fontSize: 18)),
                )),
              ..._purchasedList.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 20, color: ArtisanalTheme.primary),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        '${item.name} (x${item.quantity.toStringAsFixed(0)})', 
                        style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink.withValues(alpha: 0.6)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo, size: 20, color: Colors.black26),
                      onPressed: () => _undoPurchase(item),
                      tooltip: 'Undo',
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DPushPin() {
    return Container(
      width: 26, height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 13, left: 13, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), shape: BoxShape.circle))),
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Colors.redAccent, Colors.red.shade900], center: const Alignment(-0.3, -0.3)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(2, 2))],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingRow(int index, ShoppingItem item) {
    bool isEditing = _editingId == item.id;
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multi-line
            children: [
              GestureDetector(
                onTap: () => _startTossSequence(item.id, item.name, item.quantity, context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: ArtisanalTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.shopping_basket_outlined, size: 18, color: ArtisanalTheme.primary),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: isEditing
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _editController,
                              autofocus: true,
                              style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.primary),
                              onSubmitted: (_) => _finishEditing(),
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                            ),
                          ),
                          _buildQtyControls(index, item),
                        ],
                      )
                    : GestureDetector(
                        onTap: () => _startEditing(item),
                        child: Text(
                          '${item.name} (x${item.quantity.toStringAsFixed(0)})', 
                          style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink),
                          softWrap: true,
                        ),
                      ),
              ),
              if (!isEditing) ...[
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.black12),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _toBuyList.removeAt(index));
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Delete',
                ),
              ],
            ],
          ),
        );
      }
    );
  }

  Widget _buildQtyControls(int index, ShoppingItem item) {
    return Row(
      children: [
        _qtyBtn(Icons.remove, () => _updateQuantity(index, -1)),
        SizedBox(width: 45, child: Text(item.quantity.toStringAsFixed(0), textAlign: TextAlign.center, style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.primary))),
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

  Widget _buildInputRow(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        controller: _inputController,
        focusNode: _focusNode,
        autofocus: true,
        style: ArtisanalTheme.hand(fontSize: 24),
        decoration: InputDecoration(
          hintText: l10n.currentLanguage == '한국어' ? '추가...' : 'Add...',
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
            const Icon(Icons.add_circle_outline, color: Colors.black12, size: 24),
            const SizedBox(width: 15),
            Text(l10n.currentLanguage == '한국어' ? '다음 항목...' : 'Next...', style: ArtisanalTheme.hand(fontSize: 22, color: Colors.black12)),
          ],
        ),
      ),
    );
  }
}

class Simple3DParchmentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFFEFDF9), Color(0xFFF2EEE2)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Offset.zero & size);
    
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.05)..style = PaintingStyle.stroke..strokeWidth = 1);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MemoPad3DPainter extends CustomPainter {
  final double windValue;
  MemoPad3DPainter({required this.windValue});

  @override
  void paint(Canvas canvas, Size size) {
    double thickness = 14.0;
    final blockDark = const Color(0xFFDCD4C4);
    
    Path shadow = Path()..moveTo(thickness, thickness)..lineTo(size.width + thickness, thickness)..lineTo(size.width + thickness + 5, size.height + thickness + 10)..lineTo(thickness - 5, size.height + thickness + 10)..close();
    canvas.drawPath(shadow, Paint()..color = Colors.black.withValues(alpha: 0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25));

    Path sideStack = Path()..moveTo(size.width, 0)..lineTo(size.width + thickness, thickness)..lineTo(size.width + thickness, size.height + thickness)..lineTo(size.width, size.height)..close();
    canvas.drawPath(sideStack, Paint()..color = blockDark);

    Path bottomStack = Path()..moveTo(0, size.height)..lineTo(size.width, size.height)..lineTo(size.width + thickness, size.height + thickness)..lineTo(thickness, size.height + thickness)..close();
    canvas.drawPath(bottomStack, Paint()..color = blockDark);

    final linePaint = Paint()..color = Colors.black.withValues(alpha: 0.08)..strokeWidth = 0.5;
    for (int i = 2; i < thickness; i += 3) {
      canvas.drawLine(Offset(i.toDouble(), size.height + i), Offset(size.width + i, size.height + i), linePaint);
      canvas.drawLine(Offset(size.width + i, i.toDouble()), Offset(size.width + i, size.height + i), linePaint);
    }

    double wave = math.sin(windValue * math.pi * 2) * 8;
    final topSheetPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFFEFDF9), Color(0xFFF2EEE2)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    double foldSize = 45.0;
    Path topSheet = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width, size.height - foldSize + (wave * 0.4))..lineTo(size.width - foldSize, size.height + wave)..lineTo(0, size.height + wave)..close();
    canvas.drawPath(topSheet.shift(const Offset(0, 2)), Paint()..color = Colors.black12..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(topSheet, topSheetPaint);

    final foldPaint = Paint()..shader = LinearGradient(colors: [const Color(0xFFD0C8B8), const Color(0xFFFDFCF7)], begin: Alignment.bottomRight, end: Alignment.topLeft).createShader(Rect.fromLTWH(size.width - foldSize, size.height - foldSize, foldSize, foldSize));
    Path foldPath = Path()..moveTo(size.width, size.height - foldSize + (wave * 0.4))..lineTo(size.width - foldSize, size.height + wave)..lineTo(size.width - foldSize * 0.15, size.height + wave - foldSize * 0.15)..close();
    canvas.drawPath(foldPath.shift(const Offset(1, 1)), Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(foldPath, foldPaint);
  }

  @override
  bool shouldRepaint(covariant MemoPad3DPainter oldDelegate) => oldDelegate.windValue != windValue;
}
