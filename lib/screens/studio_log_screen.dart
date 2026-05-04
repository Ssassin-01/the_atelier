import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../widgets/artisanal_image.dart';
import 'recipe_detail_screen.dart';

class StudioLogScreen extends ConsumerStatefulWidget {
  const StudioLogScreen({super.key});

  @override
  ConsumerState<StudioLogScreen> createState() => _StudioLogScreenState();
}

class _StudioLogScreenState extends ConsumerState<StudioLogScreen> with TickerProviderStateMixin {
  Recipe? _selectedRecipe;
  Offset _startOffset = Offset.zero;
  late AnimationController _previewController;
  
  // Sequences
  late Animation<double> _lidOpacity;
  late Animation<Offset> _lidPosition;
  late Animation<double> _flyProgress;
  late Animation<double> _textReveal;

  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _lidOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _previewController, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
    _lidPosition = Tween<Offset>(begin: Offset.zero, end: const Offset(0.3, -0.8)).animate(
      CurvedAnimation(parent: _previewController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _flyProgress = CurvedAnimation(
      parent: _previewController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeInOutCubic),
    );

    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _previewController, curve: const Interval(0.85, 1.0, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  void _onItemTapped(Recipe recipe, BuildContext itemContext) {
    final RenderBox box = itemContext.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    
    setState(() {
      _selectedRecipe = recipe;
      _startOffset = position;
    });
    _previewController.forward();
  }

  void _closePreview() {
    _previewController.reverse().then((_) {
      setState(() {
        _selectedRecipe = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);

    return Container(
      color: const Color(0xFFF0EBE3),
      child: Stack(
        children: [
          ClipRect(
            child: Scaffold(
              backgroundColor: const Color(0xFFF0EBE3),
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, l10n),
                  SliverToBoxAdapter(
                    child: Container(
                      width: MediaQuery.of(context).size.width + 2,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/wallpaper.png'),
                          repeat: ImageRepeat.repeat,
                          opacity: 0.12,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildChalkboard(context, l10n, recipes),
                          ..._buildShelvesList(context, recipes),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_selectedRecipe != null) _buildSeamlessPreviewOverlay(context),
        ],
      ),
    );
  }

  Widget _buildSeamlessPreviewOverlay(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Adjust center offset for the new rectangular canvas
    final canvasWidth = 280.0;
    final canvasHeight = 340.0;
    final centerOffset = Offset(screenSize.width / 2 - canvasWidth / 2, screenSize.height / 2 - canvasHeight / 2 - 40);

    return AnimatedBuilder(
      animation: _previewController,
      builder: (context, child) {
        final currentPos = Offset.lerp(
          Offset(_startOffset.dx + 20, _startOffset.dy + 30),
          centerOffset,
          _flyProgress.value,
        )!;

        // Animate size of the paper canvas
        final currentWidth = 75.0 + ((canvasWidth - 75.0) * _flyProgress.value);
        final currentHeight = 75.0 + ((canvasHeight - 75.0) * _flyProgress.value);
        final paperCornerRadius = 2.0 + (6.0 * _flyProgress.value);

        return Stack(
          children: [
            Opacity(
              opacity: (_flyProgress.value * 1.2).clamp(0.0, 1.0),
              child: GestureDetector(
                onTap: _closePreview,
                child: Container(color: Colors.black.withValues(alpha: 0.75)),
              ),
            ),

            // CLOSE BUTTON (Top Right)
            if (_previewController.value > 0.8)
              Positioned(
                top: 50,
                right: 24,
                child: Opacity(
                  opacity: _textReveal.value,
                  child: IconButton(
                    onPressed: _closePreview,
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),

            // THE FLYING ARTISANAL CANVAS
            Positioned(
              left: currentPos.dx,
              top: currentPos.dy,
              child: GestureDetector(
                onTap: () {
                  if (_previewController.value > 0.9) {
                    final recipe = _selectedRecipe!;
                    _closePreview();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
                    );
                  }
                },
                child: Transform.rotate(
                  angle: (1.0 - _flyProgress.value) * -0.5,
                  child: Container(
                    width: currentWidth,
                    height: currentHeight,
                    padding: EdgeInsets.all(12 * _flyProgress.value),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(paperCornerRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5 * _flyProgress.value),
                          blurRadius: 30 * _flyProgress.value,
                          offset: Offset(0, 15 * _flyProgress.value),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // The Photo (Circular on plate, slightly rounded square on paper)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(math.max(100.0 * (1.0 - _flyProgress.value), 4.0)),
                              boxShadow: [
                                if (_flyProgress.value > 0.5)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    spreadRadius: -2,
                                  ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(math.max(100.0 * (1.0 - _flyProgress.value), 4.0)),
                              child: ArtisanalImage(
                                imagePath: _selectedRecipe!.mainImageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Paper Bottom Space (for text reveal)
                        if (_flyProgress.value > 0.7)
                          SizedBox(height: 20 * _flyProgress.value),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // TEXT REVEAL (Layered on top of the canvas area)
            if (_previewController.value > 0.8)
              Positioned(
                top: centerOffset.dy + canvasHeight + 10,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _textReveal.value,
                  child: Column(
                    children: [
                      Text(
                        _selectedRecipe!.name,
                        textAlign: TextAlign.center,
                        style: ArtisanalTheme.hand(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _selectedRecipe!.description ?? "Artisanal bakery archive...",
                          textAlign: TextAlign.center,
                          style: ArtisanalTheme.hand(fontSize: 16, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "TAP TO OPEN FULL RECIPE",
                          style: ArtisanalTheme.hand(
                            fontSize: 11,
                            color: ArtisanalTheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 60,
      backgroundColor: const Color(0xFFF0EBE3),
      elevation: 0,
      pinned: true,
      centerTitle: true,
      title: Text(
        l10n.studioLog,
        style: ArtisanalTheme.hand(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4A3428),
        ),
      ),
    );
  }

  Widget _buildChalkboard(BuildContext context, AppLocalizations l10n, List<Recipe> recipes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(-0.12),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/wood_shelf.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Color(0xFF3E2723), BlendMode.multiply),
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 20)),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [Color(0xFF2A2A2A), Color(0xFF0F0F0F)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChalkStat(l10n.totalRecipes, recipes.length.toString()),
                Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.05)),
                _buildChalkStat(l10n.totalSteps, recipes.fold(0, (sum, r) => sum + r.components.fold(0, (s, c) => s + c.steps.length)).toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChalkStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: ArtisanalTheme.hand(
            color: Colors.white.withValues(alpha: 0.98),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ).copyWith(
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.6), offset: const Offset(1, 1), blurRadius: 4)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: ArtisanalTheme.hand(color: Colors.white38, fontSize: 10, letterSpacing: 2),
        ),
      ],
    );
  }

  List<Widget> _buildShelvesList(BuildContext context, List<Recipe> recipes) {
    const int itemsPerShelf = 3;
    final int shelfCount = math.max((recipes.length / itemsPerShelf).ceil(), 3);
    
    return List.generate(shelfCount, (index) {
      final shelfRecipes = recipes.skip(index * itemsPerShelf).take(itemsPerShelf).toList();
      return _buildSingleArtisanalShelf(context, shelfRecipes, index);
    });
  }

  Widget _buildSingleArtisanalShelf(BuildContext context, List<Recipe> recipes, int shelfIndex) {
    return Container(
      margin: const EdgeInsets.only(top: 100, bottom: 40),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-0.9),
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFC4A484),
                image: const DecorationImage(
                  image: AssetImage('assets/images/wood_shelf.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 25)),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/wood_shelf.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 5)),
              ],
            ),
          ),
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (i) {
                if (i < recipes.length) {
                  return Builder(builder: (itemContext) {
                    return _buildInteractiveCloche(itemContext, recipes[i]);
                  });
                } else {
                  return const SizedBox(width: 100);
                }
              }),
            ),
          ),
          Positioned(
            bottom: -55,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(3, (i) {
                if (i < recipes.length) {
                  return Builder(builder: (itemContext) {
                    return _buildArtisanalNameTag(itemContext, recipes[i]);
                  });
                } else {
                  return const SizedBox(width: 100);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCloche(BuildContext itemContext, Recipe recipe) {
    final isSelected = _selectedRecipe?.id == recipe.id;
    final hasImage = recipe.mainImageUrl != null && recipe.mainImageUrl!.isNotEmpty;
    
    return GestureDetector(
      onTap: () => _onItemTapped(recipe, itemContext),
      child: SizedBox(
        width: 120,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. CERAMIC PLATE
            Transform(
              transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(-0.9),
              alignment: Alignment.center,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  gradient: const RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [Color(0xFFFFFFFF), Color(0xFFF5F2F0), Color(0xFFE5E0DA)],
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 15, offset: const Offset(0, 10)),
                  ],
                ),
              ),
            ),
            
            // 2. TILTED RECIPE CARD
            Opacity(
              opacity: (isSelected && _previewController.value > 0.3) ? 0.0 : 1.0,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(-0.9)
                  ..translate(0.0, 0.0, -1.0),
                alignment: Alignment.center,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: hasImage
                        ? ArtisanalImage(imagePath: recipe.mainImageUrl, fit: BoxFit.cover)
                        : Container(color: const Color(0xFFF5F2EA)),
                  ),
                ),
              ),
            ),

            // 3. THE 3D CLOCHE ASSEMBLY
            AnimatedBuilder(
              animation: _previewController,
              builder: (context, child) {
                final opacity = isSelected ? _lidOpacity.value : 1.0;
                final offset = isSelected ? _lidPosition.value : Offset.zero;
                
                return Transform.translate(
                  offset: Offset(offset.dx * 120, offset.dy * 120),
                  child: Opacity(
                    opacity: opacity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ...List.generate(18, (index) {
                          double elevation = -1.0 - (index * 2.0);
                          double borderOpacity = 0.25 - (index * 0.012);
                          double fillOpacity = 0.04 - (index * 0.002);
                          double scale = 1.0 - (math.pow(index / 18.0, 2) * 0.22);
                          
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(-0.9)
                              ..translate(0.0, 0.0, elevation)
                              ..scale(scale),
                            alignment: Alignment.center,
                            child: Container(
                              width: 105,
                              height: 105,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: fillOpacity > 0 ? fillOpacity : 0),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: borderOpacity > 0 ? borderOpacity : 0),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          );
                        }),
                        // Knob
                        Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(-0.9)
                            ..translate(0.0, 0.0, -42.0)
                            ..scale(0.78),
                          alignment: Alignment.center,
                          child: Transform.translate(
                            offset: const Offset(0, -8),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  center: Alignment(-0.4, -0.4),
                                  radius: 0.7,
                                  colors: [Colors.white, Color(0xFFB0BEC5), Color(0xFF455A64)],
                                  stops: [0.0, 0.6, 1.0],
                                ),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 0.5),
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
          ],
        ),
      ),
    );
  }

  Widget _buildArtisanalNameTag(BuildContext itemContext, Recipe recipe) {
    return GestureDetector(
      onTap: () => _onItemTapped(recipe, itemContext),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(color: Color(0xFF8B6B58), shape: BoxShape.circle),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFCF7),
              borderRadius: BorderRadius.circular(1),
              border: Border.all(color: const Color(0xFFDED9CD), width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(2, 4)),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 100),
            child: Column(
              children: [
                Text(
                  recipe.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ArtisanalTheme.hand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4E342E),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Container(width: 20, height: 0.5, color: const Color(0xFFDED9CD)),
                const SizedBox(height: 2),
                Text(
                  "ARTISANAL BAKE",
                  style: ArtisanalTheme.hand(fontSize: 5, color: const Color(0xFF8B6B58), letterSpacing: 0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
