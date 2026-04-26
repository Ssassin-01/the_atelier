import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/polaroid_card.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/crumple_effect.dart';
import '../models/recipe.dart';
import '../models/component.dart';
import '../services/recipe_service.dart';
import 'summary_note_screen.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _crumpleController;

  @override
  void initState() {
    super.initState();
    _crumpleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _crumpleController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteRecord.toUpperCase(), style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold)),
        content: Text(l10n.removeMediaConfirm, style: ArtisanalTheme.hand(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.redInk, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _crumpleController.forward();
      if (mounted) {
        await ref.read(recipeListProvider.notifier).removeRecipe(widget.recipe.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _onEdit() {
    // Map existing recipe to draft
    final draft = RecipeDraft(
      name: widget.recipe.name,
      mainImagePath: widget.recipe.mainImageUrl,
      components: widget.recipe.components.map((c) => RecipeComponentDraft(
        id: DateTime.now().toString(),
        title: c.title,
        imagePath: c.imageUrl,
        ingredients: c.ingredients.map((i) => IngredientEntry(
          id: DateTime.now().toString(),
          name: i.name,
          weight: double.tryParse(i.amount) ?? 0.0,
        )).toList(),
        steps: c.steps.map((s) => RecipeStepDraft(
          id: DateTime.now().toString(),
          content: s.description,
        )).toList(),
      )).toList(),
    );

    // Seed the provider
    ref.read(recipeDraftProvider.notifier).state = draft;

    // Navigate to AddRecipeScreen in edit mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecipeScreen(
          editingRecipeId: widget.recipe.id,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);
    final recipe = recipes.firstWhere((r) => r.id == widget.recipe.id, orElse: () => widget.recipe);

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 540,
            floating: false,
            pinned: true,
            backgroundColor: ArtisanalTheme.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: ArtisanalTheme.ink),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: _onEdit,
                child: Text(l10n.rename.toUpperCase(), style: ArtisanalTheme.hand(color: ArtisanalTheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: _confirmDelete,
                icon: Icon(Icons.delete_outline, color: ArtisanalTheme.redInk.withValues(alpha: 0.7)),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        recipe.name,
                        textAlign: TextAlign.center,
                        style: ArtisanalTheme.lightTheme.textTheme.displayMedium
                            ?.copyWith(fontSize: 34),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        const WashiTape(width: 100, rotation: -0.05),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: PolaroidCard(
                            width: 280,
                            image: ArtisanalImage(
                              imagePath: recipe.mainImageUrl,
                              fit: BoxFit.cover,
                            ),
                            title: l10n.autumnMenu24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: CrumpleEffect(
              controller: _crumpleController,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFBF9F6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(36),
                            topRight: Radius.circular(36),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.04),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
  
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 30),
  
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SummaryNoteScreen(recipe: recipe),
                              ),
                            ),
                            icon: const Icon(Icons.menu_book, size: 20),
                            label: Text(
                              l10n.openJournalSummary,
                              style: ArtisanalTheme.hand(fontSize: 18),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: ArtisanalTheme.ink,
                              backgroundColor: ArtisanalTheme.secondary
                                  .withValues(alpha: 0.05),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
  
                        const SizedBox(height: 60),
  
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Column(
                            children: [
                              ...recipe.components.map(
                                (comp) => AnimatedRecipePostIt(component: comp),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
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
}

class AnimatedRecipePostIt extends StatefulWidget {
  final RecipeComponent component;

  const AnimatedRecipePostIt({super.key, required this.component});

  @override
  State<AnimatedRecipePostIt> createState() => _AnimatedRecipePostItState();
}

class _AnimatedRecipePostItState extends State<AnimatedRecipePostIt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    double delta = details.primaryDelta! / 320.0;
    _controller.value -= delta;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5 || details.primaryVelocity! < -300) {
      _controller.forward().then((_) => setState(() => _isFront = false));
    } else {
      _controller.reverse().then((_) => setState(() => _isFront = true));
    }
  }

  void _onTap() {
    if (_isFront) {
      _controller.forward().then((_) => setState(() => _isFront = false));
    } else {
      _controller.reverse().then((_) => setState(() => _isFront = true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: GestureDetector(
        onTap: _onTap,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // INTERACTIVE FLIP BUILDER
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final angle = _controller.value * math.pi;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0008)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: angle < math.pi / 2
                      ? _postItWrapper(
                          _buildIngredientsContent(),
                          widget.component.imageUrl,
                        )
                      : Transform(
                          transform: Matrix4.identity()..rotateY(math.pi),
                          alignment: Alignment.center,
                          child: _postItWrapper(
                            _buildMethodsContent(l10n),
                            widget.component.imageUrl,
                          ),
                        ),
                );
              },
            ),

            // Tab Indicators
            Positioned(
              top: 25,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _simpleTab(l10n.tabIngredients, _controller.value < 0.5),
                  const SizedBox(width: 20),
                  _simpleTab(l10n.tabMethods, _controller.value >= 0.5),
                ],
              ),
            ),

            // DYNAMIC WASHI TAPE (Reacts to flip tension)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Sticker tilts slightly as the paper flips
                final tension = math.sin(_controller.value * math.pi) * 0.04;
                return Positioned(
                  top: -15,
                  child: WashiTape(
                    width: 90,
                    rotation: 0.012 + tension, // Add dynamic tilt
                    opacity: 0.85,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPolaroid(String imagePath) {
    return Container(
      width: 80,
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: ArtisanalImage(imagePath: imagePath, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildIngredientsContent() {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: 180,
          child: Text(
            widget.component.title,
            style: ArtisanalTheme.hand(fontSize: 26, color: ArtisanalTheme.ink)
                .copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 20),
        ...() {
          final totalFlour = widget.component.ingredients
              .where((ing) => ing.isFlour)
              .fold(0.0, (sum, ing) => sum + (double.tryParse(ing.amount) ?? 0));

          return widget.component.ingredients.map(
            (ing) {
              final weight = double.tryParse(ing.amount) ?? 0;
              final percentage =
                  totalFlour > 0 ? (weight / totalFlour) * 100 : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              ing.name,
                              style: ArtisanalTheme.hand(
                                  fontSize: 19, height: 1.25),
                            ),
                          ),
                          if (totalFlour > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: ArtisanalTheme.hand(
                                fontSize: 15,
                                color: ArtisanalTheme.secondary
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ing.amount}${ing.unit}',
                      style: ArtisanalTheme.hand(
                        fontSize: 19,
                        color: ArtisanalTheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.bottomRight,
          child: Opacity(
            opacity: 0.3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.currentLanguage == '한국어' ? '밀어서 넘기기' : 'Slide or tap to flip',
                  style: ArtisanalTheme.hand(fontSize: 14),
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: ArtisanalTheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodsContent(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: 180,
          child: Text(
            l10n.currentLanguage == '한국어' ? '조리법: ${widget.component.title}' : 'Method: ${widget.component.title}',
            style: ArtisanalTheme.hand(
              fontSize: 22,
              color: ArtisanalTheme.primary,
            ).copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 20),
        ...widget.component.steps
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key + 1}. ',
                      style: ArtisanalTheme.hand(
                        fontSize: 18,
                        color: ArtisanalTheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.value.description,
                        style: ArtisanalTheme.hand(fontSize: 18, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.bottomLeft,
          child: Opacity(
            opacity: 0.3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: ArtisanalTheme.secondary,
                ),
                Text(
                  l10n.tabIngredients,
                  style: ArtisanalTheme.hand(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _simpleTab(String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? ArtisanalTheme.primary : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
      child: Text(
        label,
        style: ArtisanalTheme.hand(
          fontSize: 16,
          color: active
              ? ArtisanalTheme.primary
              : ArtisanalTheme.secondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _postItWrapper(Widget child, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(28, 56, 28, 28),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9E7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: child,
          ),
          if (imageUrl != null)
            Positioned(
              top: 50,
              right: 15,
              child: Transform.rotate(
                angle: 0.08,
                child: _buildMiniPolaroid(imageUrl),
              ),
            ),
        ],
      ),
    );
  }
}
