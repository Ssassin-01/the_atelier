import 'dart:io';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
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

  ShoppingItem copyWith({
    String? id,
    String? name,
    double? quantity,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }
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
  
  final List<String> _commonIngredients = [
    '밀가루', '설탕', '버터', '달걀', '우유', '이스트', '소금', '베이킹파우더', '초콜릿', '생크림', '바닐라 익스트랙', '호두'
  ];

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
    
    // Auto-save listener for new items
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isAdding) {
        _addItem();
      }
    });
  }

  void _addItem() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      if (mounted) setState(() => _isAdding = false);
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

  Future<void> _toggleItem(ShoppingItem item, bool isPurchased) async {
    if (_editingId != null) _finishEditing();
    
    HapticFeedback.lightImpact();
    
    final isBasic = ref.read(settingsProvider).appMode == 'basic';
    
    if (isBasic) {
      // Immediate toggle for basic mode
      setState(() {
        if (isPurchased) {
          _purchasedList.removeWhere((it) => it.id == item.id);
          _toBuyList.add(item);
        } else {
          _toBuyList.removeWhere((it) => it.id == item.id);
          _purchasedList.add(item);
        }
      });
      return;
    }

    // Original toss sequence for other modes
    if (!isPurchased) {
      // Note: In creative/business mode, we need a BuildContext for the toss animation.
      // This is handled by the individual row's callback.
    } else {
      _undoPurchase(item);
    }
  }

  Future<void> _startTossSequence(String id, String name, double qty, BuildContext itemContext) async {
    if (_editingId != null) _finishEditing();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearAll() {
    HapticFeedback.heavyImpact();
    setState(() {
      _toBuyList.clear();
      _purchasedList.clear();
    });
  }

  void _showQuickAddSheet(AppLocalizations l10n) {
    bool isEditingFavorites = false;
    bool wasKeyboardVisible = false;
    final TextEditingController customController = TextEditingController();
    final ScrollController modalScrollController = ScrollController();
    final FocusNode customFocusNode = FocusNode();

    void addNewIngredient(String val, StateSetter setModalState) {
      if (val.trim().isEmpty) return;
      final newName = val.trim();
      
      setState(() {
        if (!_commonIngredients.contains(newName)) {
          _commonIngredients.add(newName);
        }
        
        final existing = _toBuyList.indexWhere((it) => it.name == newName);
        if (existing != -1) {
          _toBuyList[existing] = _toBuyList[existing].copyWith(
            quantity: _toBuyList[existing].quantity + 1,
          );
        } else {
          _toBuyList.add(ShoppingItem(
            id: DateTime.now().toString() + newName,
            name: newName,
          ));
        }
        _scrollToBottom();
      });

      customController.clear();
      setModalState(() {});
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (modalScrollController.hasClients) {
          modalScrollController.animateTo(
            modalScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      HapticFeedback.mediumImpact();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.05),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final bool isKeyboardVisible = keyboardHeight > 0;
          
          // Trigger scroll to bottom when keyboard appears or focus is gained
          if (isKeyboardVisible && !wasKeyboardVisible) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (modalScrollController.hasClients) {
                modalScrollController.animateTo(
                  modalScrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              }
            });
          }
          wasKeyboardVisible = isKeyboardVisible;

          return Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: Container(
              height: MediaQuery.of(context).size.height * (isKeyboardVisible ? 0.85 : 0.55),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFCF8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: kIsWeb
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment.topCenter,
                                  radius: 1.5,
                                  colors: [
                                    ArtisanalTheme.primary.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            )
                          : Image.file(
                              File(r'C:\Users\user b\.gemini\antigravity\brain\d6e27a52-f8db-4b74-899e-341c4de4f436\premium_dark_oak_pantry_shelf_texture_1778061659645.png'),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(),
                            ),
                    ),
                  ),

                  // Content
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) => Padding(
                        padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Handle
                            Center(
                              child: Container(
                                width: 48,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                            ),

                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        isEditingFavorites ? Icons.edit_note : Icons.add_circle_outline, 
                                        size: 28, 
                                        color: ArtisanalTheme.primary.withValues(alpha: 0.6)
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        isEditingFavorites 
                                          ? (l10n.currentLanguage == '한국어' ? '재료 수정' : 'Edit Ingredients')
                                          : (l10n.currentLanguage == '한국어' ? '재료 창고' : 'Atelier Pantry'),
                                        style: ArtisanalTheme.hand(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: ArtisanalTheme.ink,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    setModalState(() => isEditingFavorites = !isEditingFavorites);
                                  },
                                  icon: Icon(
                                    isEditingFavorites ? Icons.check : Icons.edit,
                                    size: 18,
                                    color: isEditingFavorites ? Colors.green.shade700 : ArtisanalTheme.primary,
                                  ),
                                  label: Text(
                                    isEditingFavorites 
                                      ? (l10n.currentLanguage == '한국어' ? '완료' : 'Done')
                                      : (l10n.currentLanguage == '한국어' ? '수정' : 'Edit'),
                                    style: ArtisanalTheme.hand(
                                      fontSize: 16,
                                      color: isEditingFavorites ? Colors.green.shade700 : ArtisanalTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: isEditingFavorites ? Colors.green.withValues(alpha: 0.1) : ArtisanalTheme.primary.withValues(alpha: 0.05),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: BorderSide(
                                        color: isEditingFavorites ? Colors.green.withValues(alpha: 0.2) : ArtisanalTheme.primary.withValues(alpha: 0.1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Grid
                            Expanded(
                              child: SingleChildScrollView(
                                controller: modalScrollController,
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 14,
                                      runSpacing: 18,
                                      children: [
                                        ..._commonIngredients.map((name) {
                                          final localizedName = l10n.currentLanguage == '한국어' ? name : _getEnglishName(name);
                                          return _buildIngredientCard(
                                            localizedName,
                                            isEditingFavorites,
                                            () {
                                              if (isEditingFavorites) {
                                                setState(() => _commonIngredients.remove(name));
                                                setModalState(() {});
                                              } else {
                                                HapticFeedback.lightImpact();
                                                setState(() {
                                                  final existing = _toBuyList.indexWhere((it) => it.name == localizedName);
                                                  if (existing != -1) {
                                                    _toBuyList[existing] = _toBuyList[existing].copyWith(
                                                      quantity: _toBuyList[existing].quantity + 1,
                                                    );
                                                  } else {
                                                    _toBuyList.add(ShoppingItem(
                                                      id: DateTime.now().toString() + name,
                                                      name: localizedName,
                                                    ));
                                                  }
                                                  _scrollToBottom();
                                                });
                                              }
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),

                            // Input
                            if (isEditingFavorites)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.1), width: 1.5),
                                  ),
                                  child: TextField(
                                    controller: customController,
                                    focusNode: customFocusNode,
                                    style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink),
                                    onSubmitted: (val) => addNewIngredient(val, setModalState),
                                    decoration: InputDecoration(
                                      hintText: l10n.currentLanguage == '한국어' ? '예: 바닐라 빈, 통밀가루...' : 'e.g., Vanilla Bean, Rye...',
                                      hintStyle: ArtisanalTheme.hand(color: ArtisanalTheme.ink.withValues(alpha: 0.3), fontSize: 18),
                                      border: InputBorder.none,
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: TextButton(
                                          onPressed: () => addNewIngredient(customController.text, setModalState),
                                          style: TextButton.styleFrom(
                                            foregroundColor: ArtisanalTheme.primary,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          child: Text(
                                            l10n.currentLanguage == '한국어' ? '등록' : 'Add',
                                            style: ArtisanalTheme.hand(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIngredientCard(String name, bool isDeleteMode, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDeleteMode ? const Color(0xFFFFF5F5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDeleteMode 
                ? Colors.red.withValues(alpha: 0.3) 
                : ArtisanalTheme.ink.withValues(alpha: 0.06),
            width: 1.2,
          ),
          boxShadow: [
            // Physical Button Shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
            // Highlight for 3D look
            const BoxShadow(
              color: Colors.white,
              blurRadius: 2,
              offset: Offset(-1, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isDeleteMode ? Colors.redAccent : ArtisanalTheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: ArtisanalTheme.hand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDeleteMode ? Colors.red.shade900 : ArtisanalTheme.ink,
                letterSpacing: 0.5,
              ),
            ),
            if (isDeleteMode) ...[
              const SizedBox(width: 12),
              const Icon(Icons.remove_circle_outline, size: 16, color: Colors.redAccent),
            ],
          ],
        ),
      ),
    );
  }

  String _getEnglishName(String ko) {
    switch (ko) {
      case '밀가루': return 'Flour';
      case '설탕': return 'Sugar';
      case '버터': return 'Butter';
      case '달걀': return 'Eggs';
      case '우유': return 'Milk';
      case '이스트': return 'Yeast';
      case '소금': return 'Salt';
      case '베이킹파우더': return 'Baking Powder';
      case '초콜릿': return 'Chocolate';
      case '생크림': return 'Cream';
      case '바닐라 익스트랙': return 'Vanilla';
      case '호두': return 'Walnut';
      default: return ko;
    }
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
    final appMode = ref.watch(settingsProvider).appMode;
    final isBasic = appMode == 'basic';
    
    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: GestureDetector(
        onTap: () {
          if (_editingId != null) _finishEditing();
          if (_isAdding) _addItem(); // Auto-add if was adding
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Fixed Wallpaper Background
            if (!isBasic)
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
            
            isBasic ? _buildBasicLayout(l10n) : _buildCreativeLayout(l10n),
            
            if (!isBasic && _flyingItemName != null) _buildFlyingItemOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicLayout(AppLocalizations l10n) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.currentLanguage == '한국어' ? '장보기 메모' : 'Shopping Note',
                  style: ArtisanalTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    color: ArtisanalTheme.ink,
                    height: 1.1,
                  ),
                ),
                IconButton(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.refresh, color: Colors.black26),
                  tooltip: 'Clear All',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9DB), // Classic Post-it Yellow
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: To Buy
                    _buildBasicSectionTitle(l10n.currentLanguage == '한국어' ? '🛒 살 것' : '🛒 To Buy'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          ..._toBuyList.asMap().entries.map((entry) => _buildBasicRow(entry.key, entry.value, false)),
                          if (_isAdding) _buildInputRow(l10n) else _buildAddTrigger(l10n),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => _showQuickAddSheet(l10n),
                              icon: const Icon(Icons.auto_awesome, size: 18, color: ArtisanalTheme.primary),
                              label: Text(
                                l10n.currentLanguage == '한국어' ? '자주 쓰는 재료 추가' : 'Quick Add Ingredients',
                                style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(height: 40, color: Colors.black12, thickness: 1),
                    ),
                    
                    // Section: In Stock
                    _buildBasicSectionTitle(l10n.currentLanguage == '한국어' ? '✅ 구매완료' : '✅ Completed'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: _purchasedList.isEmpty 
                        ? Center(child: Text(l10n.currentLanguage == '한국어' ? '비어 있음' : 'Empty', style: ArtisanalTheme.hand(color: Colors.black12, fontSize: 16)))
                        : Column(
                            children: _purchasedList.map((item) => _buildBasicRow(-1, item, true)).toList(),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Text(
        title,
        style: ArtisanalTheme.hand(fontSize: 18, fontWeight: FontWeight.bold, color: ArtisanalTheme.primary.withValues(alpha: 0.5), letterSpacing: 1),
      ),
    );
  }

  Widget _buildBasicRow(int index, ShoppingItem item, bool isPurchased) {
    bool isEditing = _editingId == item.id;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5))),
      child: Row(
        children: [
          Checkbox(
            value: isPurchased,
            onChanged: (_) => _toggleItem(item, isPurchased),
            activeColor: ArtisanalTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Colors.black12, width: 1.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isEditing
                ? TapRegion(
                    onTapOutside: (_) => _finishEditing(), // Save only when tapping outside the whole editing area
                    child: Row(
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
                    ),
                  )
                : GestureDetector(
                    onTap: () => isPurchased ? _toggleItem(item, isPurchased) : _startEditing(item),
                    child: Text(
                      item.name, 
                      style: ArtisanalTheme.hand(
                        fontSize: 22, 
                        color: isPurchased ? Colors.black26 : ArtisanalTheme.ink,
                      ).copyWith(decoration: isPurchased ? TextDecoration.lineThrough : null),
                    ),
                  ),
          ),
          // Quantity and Delete button for Basic Mode (when not editing)
          if (!isEditing && !isPurchased) ...[
            GestureDetector(
              onTap: () => _startEditing(item),
              child: Text('x${item.quantity.toStringAsFixed(0)}', style: ArtisanalTheme.hand(fontSize: 18, color: Colors.black26)),
            ),
            
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.black12),
              onPressed: () {
                setState(() => _toBuyList.removeAt(index));
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
          if (isPurchased) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ArtisanalTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore, size: 18, color: ArtisanalTheme.primary),
                    onPressed: () => _undoPurchase(item),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    tooltip: 'Restore',
                  ),
                  const SizedBox(width: 4),
                  Container(width: 1, height: 12, color: Colors.black12),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: () {
                      setState(() => _purchasedList.removeWhere((it) => it.id == item.id));
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreativeLayout(AppLocalizations l10n) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 80,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false, // Left aligned
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              l10n.currentLanguage == '한국어' ? '식재료 공정' : 'PANTRY PROCESS',
              style: ArtisanalTheme.lightTheme.textTheme.displayLarge?.copyWith(
                fontSize: 32,
                color: ArtisanalTheme.ink,
                height: 1.1,
              ),
            ),
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
        _buildSectionHeader(l10n.currentLanguage == '한국어' ? '구매완료' : 'COMPLETED', sectionKey: _purchasedSectionKey),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 45, 100),
            child: _buildPurchasedParchment(context, l10n),
          ),
        ),
      ],
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
                        IconButton(
                          onPressed: _clearAll,
                          icon: const Icon(Icons.refresh, size: 18, color: Colors.black12),
                          tooltip: 'Reset List',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 15),
                        _build3DPushPin(),
                      ],
                    ),
                    const Divider(height: 40, color: Colors.black12),
                    ..._toBuyList.asMap().entries.map((entry) => _buildShoppingRow(entry.key, entry.value)),
                    if (_isAdding) _buildInputRow(l10n) else _buildAddTrigger(l10n),
                    const SizedBox(height: 20),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQuickAddSheet(l10n),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: Text(l10n.currentLanguage == '한국어' ? '자주 쓰는 재료' : 'Quick Add', style: ArtisanalTheme.hand()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ArtisanalTheme.primary.withValues(alpha: 0.4),
                          side: BorderSide(color: ArtisanalTheme.primary.withValues(alpha: 0.2)),
                        ),
                      ),
                    ),
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      l10n.currentLanguage == '한국어' ? '아직 담은 제품이 없습니다' : 'Nothing collected yet',
                      style: ArtisanalTheme.hand(color: Colors.black12, fontSize: 18),
                    ),
                  ),
                )
              else
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
                    )),
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
                    ? TapRegion(
                        onTapOutside: (_) => _finishEditing(),
                        child: Row(
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
                        ),
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
        onSubmitted: (_) => _addItem(),
        decoration: InputDecoration(
          hintText: l10n.currentLanguage == '한국어' ? '추가...' : 'Add...',
          border: InputBorder.none,
          icon: const Icon(Icons.edit, size: 24, color: ArtisanalTheme.primary),
        ),
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
