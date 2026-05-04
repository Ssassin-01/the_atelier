import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/masking_tape.dart';
import '../widgets/custom_clippers.dart';
import 'recipe_detail_screen.dart';

class StudioLogScreen extends ConsumerStatefulWidget {
  const StudioLogScreen({super.key});

  @override
  ConsumerState<StudioLogScreen> createState() => _StudioLogScreenState();
}

class _StudioLogScreenState extends ConsumerState<StudioLogScreen>
    with TickerProviderStateMixin {
  Recipe? _selectedRecipe;
  Offset _startOffset = Offset.zero;
  late AnimationController _previewController;
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  String _searchQuery = '';

  // Sequences
  late Animation<double> _lidOpacity;
  late Animation<Offset> _lidPosition;
  late Animation<double> _flyProgress;
  late Animation<double> _textReveal;
  late Animation<double> _openProgress;

  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _lidOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _previewController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic),
      ),
    );
    // _lidPosition is removed. Movement is now directly calculated from _openProgress for perfect sync.

    _flyProgress = CurvedAnimation(
      parent: _previewController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeInOutCubic),
    );

    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _previewController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );
    _openProgress = CurvedAnimation(
      parent: _previewController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _previewController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
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
    _previewController.duration = const Duration(
      milliseconds: 500,
    ); // Fast close
    _previewController.reverse().then((_) {
      setState(() {
        _selectedRecipe = null;
      });
      _previewController.duration = const Duration(
        milliseconds: 1200,
      ); // Reset for next open
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allRecipes = ref.watch(recipeListProvider);

    // Filter recipes based on search query
    final recipes = allRecipes.where((recipe) {
      if (_searchQuery.isEmpty) return true;
      return recipe.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      color: const Color(0xFFF0EBE3),
      child: Stack(
        children: [
          ClipRect(
            child: Scaffold(
              backgroundColor: const Color(0xFFF0EBE3),
              body: CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
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
                          _buildSearchParchment(context, l10n),
                          ..._buildShelvesList(context, recipes, l10n),
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedRecipe != null)
            _buildSeamlessPreviewOverlay(context, l10n),
        ],
      ),
    );
  }

  Widget _buildSeamlessPreviewOverlay(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final canvasWidth = 280.0;
    final canvasHeight = 340.0;

    const double topPadding = 100.0;
    final centerOffset = Offset(
      screenSize.width / 2 - canvasWidth / 2,
      topPadding,
    );

    return AnimatedBuilder(
      animation: _previewController,
      builder: (context, child) {
        final currentPos = Offset.lerp(
          Offset(_startOffset.dx + 20, _startOffset.dy + 30),
          centerOffset,
          _flyProgress.value,
        )!;

        final currentWidth = 75.0 + ((canvasWidth - 75.0) * _flyProgress.value);
        final currentHeight =
            75.0 + ((canvasHeight - 75.0) * _flyProgress.value);
        final paperCornerRadius = 2.0 + (6.0 * _flyProgress.value);
        final initial = _selectedRecipe!.name.isNotEmpty
            ? _selectedRecipe!.name[0].toUpperCase()
            : '?';
        final hasImage =
            _selectedRecipe!.mainImageUrl != null &&
            _selectedRecipe!.mainImageUrl!.isNotEmpty;

        return Stack(
          children: [
            Opacity(
              opacity: (_flyProgress.value * 1.2).clamp(0.0, 1.0),
              child: GestureDetector(
                onTap: _closePreview,
                child: Container(color: Colors.black.withValues(alpha: 0.75)),
              ),
            ),

            if (_previewController.value > 0.9)
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(top: topPadding, bottom: 80),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final recipe = _selectedRecipe!;
                          _closePreview();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none, // Allow sticker to bleed out
                          children: [
                            // 1. THE WHITE PAPER CANVAS
                            Container(
                              width: canvasWidth,
                              height: canvasHeight,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  paperCornerRadius,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child:
                                      (_selectedRecipe!.mainImageUrl != null &&
                                          _selectedRecipe!
                                              .mainImageUrl!
                                              .isNotEmpty)
                                      ? ArtisanalImage(
                                          imagePath:
                                              _selectedRecipe!.mainImageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: const Color(0xFFFDFCF7),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Opacity(
                                                opacity: 0.15,
                                                child: Container(
                                                  width: canvasWidth * 0.7,
                                                  height: canvasWidth * 0.7,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFF4E342E,
                                                      ),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                initial,
                                                style: ArtisanalTheme.hand(
                                                  fontSize: 120,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF4E342E,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            // 2. THE MASKING TAPE STICKER (OUTER)
                            if (_previewController.value > 0.95)
                              Positioned(
                                top: -16, // Truly overlaps the white edge now
                                child: Opacity(
                                  opacity: _textReveal.value,
                                  child: Transform.rotate(
                                    angle: -0.04,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF9E5),
                                        borderRadius: BorderRadius.circular(1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(1, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF8B6B58,
                                              ).withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.viewFullRecipe.toUpperCase(),
                                            style: ArtisanalTheme.hand(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF8B6B58),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Opacity(
                        opacity: _textReveal.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              Text(
                                _selectedRecipe!.name,
                                textAlign: TextAlign.center,
                                style: ArtisanalTheme.hand(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(
                                _selectedRecipe!.description ??
                                    l10n.artisanalArchive,
                                textAlign: TextAlign.center,
                                style: ArtisanalTheme.hand(
                                  fontSize: 17,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // CLOSE BUTTON (X) - Moved to top of stack
            if (_previewController.value > 0.8)
              Positioned(
                top: 50,
                right: 24,
                child: Opacity(
                  opacity: _textReveal.value,
                  child: IconButton(
                    onPressed: _closePreview,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),

            if (_previewController.value <= 0.9)
              Positioned(
                left: currentPos.dx,
                top: currentPos.dy,
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
                          color: Colors.black.withValues(
                            alpha: 0.5 * _flyProgress.value,
                          ),
                          blurRadius: 30 * _flyProgress.value,
                          offset: Offset(0, 15 * _flyProgress.value),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                math.max(
                                  100.0 * (1.0 - _flyProgress.value),
                                  4.0,
                                ),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                math.max(
                                  100.0 * (1.0 - _flyProgress.value),
                                  4.0,
                                ),
                              ),
                              child: hasImage
                                  ? ArtisanalImage(
                                      imagePath: _selectedRecipe!.mainImageUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: const Color(0xFFFDFCF7),
                                      child: Center(
                                        child: Text(
                                          initial,
                                          style: ArtisanalTheme.hand(
                                            fontSize:
                                                40.0 +
                                                (80.0 * _flyProgress.value),
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF4E342E),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        if (_flyProgress.value > 0.7)
                          SizedBox(height: 20 * _flyProgress.value),
                      ],
                    ),
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

  Widget _buildChalkboard(
    BuildContext context,
    AppLocalizations l10n,
    List<Recipe> recipes,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 10,
      ), // Reduced from 20
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015) // Smoother perspective
          ..rotateX(0.15), // More gentle 'looking up' angle
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/wood_shelf.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color(0xFF3E2723),
                BlendMode.multiply,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
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
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChalkStat(l10n.totalRecipes, recipes.length.toString()),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                _buildChalkStat(
                  l10n.totalSteps,
                  recipes
                      .fold(
                        0,
                        (sum, r) =>
                            sum +
                            r.components.fold(0, (s, c) => s + c.steps.length),
                      )
                      .toString(),
                ),
                if (recipes.isEmpty) ...[
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(recipeListProvider.notifier).seedSamples(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFC4A484),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.loadSamples.toUpperCase(),
                          style: ArtisanalTheme.hand(
                            color: const Color(0xFFC4A484),
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
          style:
              ArtisanalTheme.hand(
                color: Colors.white.withValues(alpha: 0.98),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ).copyWith(
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    offset: const Offset(1, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: ArtisanalTheme.hand(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildShelvesList(
    BuildContext context,
    List<Recipe> recipes,
    AppLocalizations l10n,
  ) {
    const int itemsPerShelf = 3;
    final int shelfCount = math.max((recipes.length / itemsPerShelf).ceil(), 3);

    return List.generate(shelfCount, (index) {
      final shelfRecipes = recipes
          .skip(index * itemsPerShelf)
          .take(itemsPerShelf)
          .toList();
      return _buildSingleArtisanalShelf(context, shelfRecipes, index, l10n);
    });
  }

  Widget _buildSingleArtisanalShelf(
    BuildContext context,
    List<Recipe> recipes,
    int shelfIndex,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        top: 23,
        bottom: 35,
      ), // Reduced from 45 to bring closer to search bar
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
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 25),
                  ),
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
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 5),
                ),
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
                  return Builder(
                    builder: (itemContext) {
                      return _buildInteractiveCloche(
                        itemContext,
                        recipes[i],
                        l10n,
                        i,
                      );
                    },
                  );
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
                  return Builder(
                    builder: (itemContext) {
                      return _buildArtisanalNameTag(itemContext, recipes[i]);
                    },
                  );
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

  Widget _buildInteractiveCloche(
    BuildContext itemContext,
    Recipe recipe,
    AppLocalizations l10n,
    int shelfItemIndex,
  ) {
    final isSelected = _selectedRecipe?.id == recipe.id;
    final hasImage =
        recipe.mainImageUrl != null && recipe.mainImageUrl!.isNotEmpty;

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
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(-0.9),
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
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF5F2F0),
                      Color(0xFFE5E0DA),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),

            // 2. TILTED RECIPE CARD
            Opacity(
              opacity: (isSelected && _previewController.value > 0.3)
                  ? 0.0
                  : 1.0,
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
                        ? ArtisanalImage(
                            imagePath: recipe.mainImageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFFFDFCF7),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: 0.1,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF4E342E),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      recipe.name.isNotEmpty
                                          ? recipe.name[0].toUpperCase()
                                          : '?',
                                      style: ArtisanalTheme.hand(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(
                                          0xFF4E342E,
                                        ).withValues(alpha: 0.8),
                                      ),
                                    ),
                                    Text(
                                      l10n.crafting.toUpperCase(),
                                      style: ArtisanalTheme.hand(
                                        fontSize: 4,
                                        color: const Color(0xFF4E342E),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // 3. THE 3D CLOCHE ASSEMBLY
            AnimatedBuilder(
              animation: _previewController,
              builder: (context, child) {
                final opacity = isSelected ? _lidOpacity.value : 1.0;
                final openProgress = _openProgress.value;

                // Determine trajectory based on position (Left: 0, Center: 1, Right: 2)
                Offset targetOffset;
                double targetRotateY;
                double targetRotateX;
                double targetRotateZ;
                Alignment targetAlignment;

                if (shelfItemIndex == 0) {
                  // Left item: Hinges on bottom-left, opens to left
                  targetOffset = const Offset(-0.3, -1.0);
                  targetRotateY = 0.9; // Doubled
                  targetRotateX = 0.5; // Increased
                  targetRotateZ = -0.4; // Doubled
                  targetAlignment = Alignment.bottomLeft;
                } else if (shelfItemIndex == 1) {
                  // Center item: Hinges on bottom-center, opens back
                  targetOffset = const Offset(0.0, -1.1);
                  targetRotateY = 0.0;
                  targetRotateX = 0.95; // Nearly double (leans far back)
                  targetRotateZ = 0.0;
                  targetAlignment = Alignment.bottomCenter;
                } else {
                  // Right item: Hinges on bottom-right, opens to right
                  targetOffset = const Offset(0.3, -1.0);
                  targetRotateY = -0.9; // Doubled
                  targetRotateX = 0.5; // Increased
                  targetRotateZ = 0.4; // Doubled
                  targetAlignment = Alignment.bottomRight;
                }

                final currentOffset = isSelected
                    ? Offset(
                        targetOffset.dx * 180 * openProgress,
                        targetOffset.dy * 150 * openProgress,
                      )
                    : Offset.zero;

                return Transform.translate(
                  offset: currentOffset,
                  child: Transform(
                    alignment: targetAlignment,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Mild perspective
                      ..rotateX(isSelected ? targetRotateX * openProgress : 0.0)
                      ..rotateY(isSelected ? targetRotateY * openProgress : 0.0)
                      ..rotateZ(
                        isSelected ? targetRotateZ * openProgress : 0.0,
                      ),
                    child: Opacity(
                      opacity: opacity,
                      child: RepaintBoundary(
                        // Performance optimization
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ...List.generate(18, (index) {
                              double elevation = -1.0 - (index * 2.0);
                              double borderOpacity = 0.25 - (index * 0.012);
                              double fillOpacity = 0.04 - (index * 0.002);
                              double scale =
                                  1.0 - (math.pow(index / 18.0, 2) * 0.22);

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
                                    color: Colors.white.withValues(
                                      alpha: fillOpacity > 0 ? fillOpacity : 0,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: borderOpacity > 0
                                            ? borderOpacity
                                            : 0,
                                      ),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            // Refined 3D Knob with 'Height' via stacking and offsets
                            Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateX(-0.9)
                                ..translate(0.0, 0.0, -42.0),
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 1. Shadow on the glass surface
                                  Transform.translate(
                                    offset: const Offset(0, 6),
                                    child: Container(
                                      width: 18,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 2. The Body of the Knob (Slightly taller for height)
                                  Transform.translate(
                                    offset: const Offset(0, -4),
                                    child: Container(
                                      width: 22,
                                      height:
                                          24, // Slightly taller for 3D volume
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(11),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFFEEEEEE),
                                            Color(0xFF9E9E9E),
                                            Color(0xFF616161),
                                          ],
                                          stops: [0.0, 0.6, 1.0],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 3. The Top Surface / Highlight
                                  Transform.translate(
                                    offset: const Offset(0, -8),
                                    child: Container(
                                      width: 20,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const RadialGradient(
                                          center: Alignment(-0.2, -0.4),
                                          radius: 0.8,
                                          colors: [
                                            Color(0xFFFFFFFF),
                                            Color(0xFFE0E0E0),
                                            Color(0xFFBDBDBD),
                                          ],
                                          stops: [0.0, 0.3, 1.0],
                                        ),
                                      ),
                                      child: Align(
                                        child: Container(
                                          width: 4,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
            decoration: const BoxDecoration(
              color: Color(0xFF8B6B58),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFCF7),
              borderRadius: BorderRadius.circular(1),
              border: Border.all(color: const Color(0xFFDED9CD), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
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
                Container(
                  width: 20,
                  height: 0.5,
                  color: const Color(0xFFDED9CD),
                ),
                const SizedBox(height: 2),
                Text(
                  "ARTISANAL BAKE",
                  style: ArtisanalTheme.hand(
                    fontSize: 5,
                    color: const Color(0xFF8B6B58),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchParchment(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0), // Top padding 0
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. TOP METALLIC ORDER RAIL
            Container(
              width: 300,
              height: 10,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFBDBDBD),
                    Color(0xFFEEEEEE),
                    Color(0xFF9E9E9E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
            ),

            // 2. COMPACT HANGING RECEIPT
            Transform.translate(
              offset: const Offset(0, -2),
              child: Container(
                width: 270,
                child: ClipPath(
                  clipper: ZigZagClipper(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Compact Search Input
                        TextField(
                          controller: _searchController,
                          onTap: () {
                            // 터치하는 순간 칠판은 완벽히 숨기고 검색창(영수증) 맨 위부터 보이도록 스크롤
                            _scrollController.animateTo(
                              200, // Fine-tuned to hide the chalkboard completely without cutting the parchment
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          onChanged: (val) {
                            setState(() => _searchQuery = val);
                          },
                          style: ArtisanalTheme.hand(
                            fontSize: 18,
                            color: ArtisanalTheme.ink,
                          ),
                          cursorColor: ArtisanalTheme.ink,
                          decoration: InputDecoration(
                            hintText: l10n.currentLanguage == '한국어'
                                ? 'SEARCH...'
                                : 'SEARCH...',
                            hintStyle: ArtisanalTheme.hand(
                              fontSize: 18,
                              color: ArtisanalTheme.ink.withValues(alpha: 0.15),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black.withValues(alpha: 0.3),
                              size: 18,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    color: Colors.black.withValues(alpha: 0.3),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          '----------------------------',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.05),
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                        ),

                        // Small Date/Order Info (Minimal)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'ORDER #0001',
                            style: ArtisanalTheme.hand(
                              fontSize: 9,
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
