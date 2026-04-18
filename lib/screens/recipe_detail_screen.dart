import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/polaroid_card.dart';
import '../widgets/artisanal_image.dart';
import '../models/recipe.dart';
import '../models/component.dart';
import 'summary_note_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 650,
            floating: false,
            pinned: true,
            backgroundColor: ArtisanalTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              background: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        recipe.name,
                        textAlign: TextAlign.center,
                        style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                          fontSize: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 40.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SummaryNoteScreen()),
                    ),
                    icon: const Icon(Icons.menu_book, size: 20),
                    label: Text(
                      'Open Journal Summary',
                      style: ArtisanalTheme.hand(fontSize: 18),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: ArtisanalTheme.ink,
                      backgroundColor: ArtisanalTheme.secondary.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                ...recipe.components.map((comp) => AnimatedRecipePostIt(component: comp)),
                const SizedBox(height: 100),
              ]),
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

class _AnimatedRecipePostItState extends State<AnimatedRecipePostIt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Relative drag to control rotation
    double delta = details.primaryDelta! / 300.0;
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
                    ..setEntry(3, 2, 0.0008) // Perspective
                    ..rotateY(angle), // Balanced center rotation
                  alignment: Alignment.center, // GO BACK TO CENTER SO IT STAYS VISIBLE
                  child: angle < math.pi / 2 
                    ? _postItWrapper(_buildIngredientsContent()) // Front face
                    : Transform(
                        transform: Matrix4.identity()..rotateY(math.pi), // Face user
                        alignment: Alignment.center,
                        child: _postItWrapper(_buildMethodsContent(l10n)),
                      ),
                );
              },
            ),
            
            // Fixed Indicators
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

            // Tape on top
            Positioned(
              top: -15,
              child: const WashiTape(
                width: 90, 
                rotation: 0.012,
                opacity: 0.85, 
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          widget.component.title,
          style: ArtisanalTheme.hand(fontSize: 26, color: ArtisanalTheme.ink).copyWith(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 20),
        ...widget.component.ingredients.map((ing) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(ing.name, style: ArtisanalTheme.hand(fontSize: 19, height: 1.25)),
              ),
              const SizedBox(width: 8),
              Text('${ing.amount}${ing.unit}', 
                   style: ArtisanalTheme.hand(fontSize: 19, color: ArtisanalTheme.secondary)),
            ],
          ),
        )),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.bottomRight,
          child: Opacity(
            opacity: 0.3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Slide or tap to flip', style: ArtisanalTheme.hand(fontSize: 14)),
                const Icon(Icons.arrow_forward, size: 14, color: ArtisanalTheme.secondary),
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
        Text(
          'Method: ${widget.component.title}',
          style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.primary).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...widget.component.steps.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${e.key + 1}. ', 
                   style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.primary)),
              Expanded(
                child: Text(e.value.description, 
                            style: ArtisanalTheme.hand(fontSize: 18, height: 1.35)),
              ),
            ],
          ),
        )).toList(),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.bottomLeft,
          child: Opacity(
            opacity: 0.3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back, size: 14, color: ArtisanalTheme.secondary),
                Text('Back to ingredients', style: ArtisanalTheme.hand(fontSize: 14)),
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
        border: Border(bottom: BorderSide(
          color: active ? ArtisanalTheme.primary : Colors.transparent, 
          width: 2.5
        )),
      ),
      child: Text(
        label,
        style: ArtisanalTheme.hand(
          fontSize: 16,
          color: active ? ArtisanalTheme.primary : ArtisanalTheme.secondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _postItWrapper(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
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
    );
  }
}
