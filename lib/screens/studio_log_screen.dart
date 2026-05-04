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

    return Container(
      color: const Color(0xFFF0EBE3),
      child: ClipRect(
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
                      _buildRestored3DChalkboard(context, l10n, recipes),
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
                  return _buildSolidGlassShowcase(context, recipes[i]);
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
                  return _buildArtisanalNameTag(recipes[i].name);
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

  Widget _buildSolidGlassShowcase(BuildContext context, Recipe recipe) {
    final hasImage = recipe.mainImageUrl != null && recipe.mainImageUrl!.isNotEmpty;
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
      ),
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
                    BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 10)),
                  ],
                ),
              ),
            ),
            
            // 2. RECIPE CARD
            Transform(
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

            // 3. ENHANCED SOLID 3D CLOCHE BODY
            ...List.generate(18, (index) {
              double elevation = -1.0 - (index * 2.0);
              // 테두리 불투명도 증가 및 부드러운 '면' 추가
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
                    color: Colors.white.withValues(alpha: fillOpacity > 0 ? fillOpacity : 0), // '면'을 채워 무게감 부여
                    border: Border.all(
                      color: Colors.white.withValues(alpha: borderOpacity > 0 ? borderOpacity : 0),
                      width: 1.2,
                    ),
                  ),
                ),
              );
            }),

            // 4. HIGH-FIDELITY GLASS DOME TOP & 3D KNOB
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(-0.9)
                ..translate(0.0, 0.0, -42.0)
                ..scale(0.78),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // THE DOME TOP (Stronger Reflection)
                  Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.25, -0.35),
                        radius: 0.9,
                        colors: [
                          Colors.white.withValues(alpha: 0.7), // 강한 조명 반사
                          Colors.white.withValues(alpha: 0.15),
                          const Color(0xFFE0F7FA).withValues(alpha: 0.3), // 선명한 유리 틴트
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                  
                  // THE 3D SPHERICAL KNOB (Redesigned)
                  Transform.translate(
                    offset: const Offset(0, -8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Knob Base Shadow (돔과 만나는 지점)
                        Transform.translate(
                          offset: const Offset(0, 6),
                          child: Container(
                            width: 12,
                            height: 6,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // The Knob Ball
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              center: Alignment(-0.4, -0.4),
                              radius: 0.7,
                              colors: [
                                Colors.white,
                                Color(0xFFB0BEC5),
                                Color(0xFF455A64),
                              ],
                              stops: [0.0, 0.6, 1.0],
                            ),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 0.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(2, 4)),
                            ],
                          ),
                        ),
                        // Specular Shine on Knob
                        Positioned(
                          top: 3,
                          left: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtisanalNameTag(String name) {
    return Column(
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
                name,
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
    );
  }
}
