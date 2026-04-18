import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/polaroid_card.dart';
import '../widgets/artisanal_image.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recipes = ref.watch(recipeListProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            // Hero Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -24,
                  left: -8,
                  child: Transform.rotate(
                    angle: -0.07,
                    child: Text(
                      '${l10n.journalNo} 42',
                      style: ArtisanalTheme.hand(
                        fontSize: 24,
                        color: ArtisanalTheme.primary.withAlpha((0.8 * 255).toInt()),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.findPerfectRecipe,
                      style: ArtisanalTheme.lightTheme.textTheme.displayLarge?.copyWith(
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.artisanalKitchenDesc,
                      style: ArtisanalTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: ArtisanalTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchRecipes,
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: ArtisanalTheme.secondary),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Recently Baked Section
            Text(
              l10n.recentlyBaked,
              style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 420,
              child: recipes.isEmpty 
                ? Center(child: Text(l10n.emptyState, style: ArtisanalTheme.hand(fontSize: 20)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipes.length > 5 ? 5 : recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      // Alternate rotations and tape colors for variety
                      final rotation = (index % 2 == 0) ? 0.04 : -0.05;
                      final tapeColor = (index % 2 == 0) 
                          ? ArtisanalTheme.primary.withAlpha((0.15 * 255).toInt())
                          : Colors.black.withAlpha((0.05 * 255).toInt());

                      return Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                          child: PolaroidCard(
                            rotation: rotation,
                            tapeColor: tapeColor,
                            title: recipe.name,
                            subtitle: recipe.description,
                            image: ArtisanalImage(
                              imagePath: recipe.mainImageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 48),
            // Collections
            Text(
              l10n.collections,
              style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 24),
            _buildCollectionsGrid(l10n),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsGrid(AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _collectionCard(l10n.collectionSourdough, 'assets/images/sourdough.png', Colors.orange[100]!),
        _collectionCard(l10n.collectionDesserts, 'assets/images/pumpkin_dessert.png', Colors.pink[50]!),
        _collectionCard(l10n.collectionPastry, 'assets/images/madeleine.png', Colors.purple[50]!),
        _collectionCard(l10n.collectionCookies, 'assets/images/cookies.png', Colors.amber[50]!),
      ],
    );
  }

  Widget _collectionCard(String title, String imagePath, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -10,
            child: Opacity(
              opacity: 0.6,
              child: ArtisanalImage(
                imagePath: imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
