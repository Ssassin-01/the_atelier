import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../widgets/artisanal_image.dart';
import 'recipe_detail_screen.dart';

class StudioLogScreen extends ConsumerWidget {
  const StudioLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, l10n),
          SliverToBoxAdapter(
            child: Container(
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
                  _buildRestored3DChalkboard(context, l10n, recipes),
                  ..._buildShelvesList(context, recipes),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildRestored3DChalkboard(BuildContext context, AppLocalizations l10n, List<Recipe> recipes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // Restored perspective
          ..rotateX(-0.12), // Restored top-down tilt
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
              // High-offset shadow to simulate 3D volume without the bug
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10), // Real wood frame thickness
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Color(0xFF2A2A2A),
                  Color(0xFF0F0F0F),
                ],
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

  List<Widget> _buildShelvesList(BuildContext context, List<Recipe> recipes) {
    const int itemsPerShelf = 3;
    final int shelfCount = math.max((recipes.length / itemsPerShelf).ceil(), 3);
    
    return List.generate(shelfCount, (index) {
      final shelfRecipes = recipes.skip(index * itemsPerShelf).take(itemsPerShelf).toList();
      return _buildSingleArtisanalShelf(context, shelfRecipes);
    });
  }

  Widget _buildSingleArtisanalShelf(BuildContext context, List<Recipe> recipes) {
    return Container(
      margin: const EdgeInsets.only(top: 60, bottom: 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-0.85),
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFC4A484),
                image: const DecorationImage(
                  image: AssetImage('assets/images/wood_shelf.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 15)),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/wood_shelf.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
          ),
          Positioned(
            bottom: 45,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (i) {
                if (i < recipes.length) {
                  return _buildShelfItem(context, recipes[i]);
                } else {
                  return const SizedBox(width: 90);
                }
              }),
            ),
          ),
          Positioned(
            bottom: -25,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(3, (i) {
                if (i < recipes.length) {
                  return _buildArtisanTag(recipes[i].name);
                } else {
                  return const SizedBox(width: 90);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelfItem(BuildContext context, Recipe recipe) {
    final hasImage = recipe.mainImageUrl != null && recipe.mainImageUrl!.isNotEmpty;
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -5,
            child: Container(
              width: 70,
              height: 15,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(4, 4)),
              ],
            ),
            child: Container(
              width: 85,
              height: 85,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Color(0xFFF5F2EA)),
              child: hasImage
                  ? ArtisanalImage(imagePath: recipe.mainImageUrl, fit: BoxFit.cover)
                  : Opacity(
                      opacity: 0.3,
                      child: Icon(Icons.bakery_dining, size: 36, color: const Color(0xFF8B6B58)),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCF7),
        borderRadius: BorderRadius.circular(1),
        border: Border.all(color: const Color(0xFFDED9CD), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(2, 4)),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 100),
      child: Text(
        name,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: ArtisanalTheme.hand(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4E342E),
          height: 1.2,
        ),
      ),
    );
  }
}
