import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/recipe_service.dart';
import '../widgets/artisanal_image.dart';
import 'recipe_detail_screen.dart';

class RecipeArchiveScreen extends ConsumerWidget {
  const RecipeArchiveScreen({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rndArchive,
                      style: ArtisanalTheme.hand(
                        fontSize: 20,
                        color: ArtisanalTheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      l10n.myRecipes,
                      style: ArtisanalTheme.lightTheme.textTheme.displayMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ArtisanalTheme.background,
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: const Icon(Icons.view_agenda, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Opacity(
                        opacity: 0.4,
                        child: Icon(Icons.grid_view, size: 20),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildFilterChip(l10n.tagVegan, isSelected: true),
                  _buildFilterChip(l10n.tagLargeBatch),
                  _buildFilterChip(l10n.tagSlowFerment),
                  _buildFilterChip(l10n.tagSourdough),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
            const SizedBox(height: 24),
            // Recipe List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final recipe = recipes[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          recipe: recipe,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: ArtisanalImage(
                              imagePath: recipe.mainImageUrl,
                              width: 120,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    style: ArtisanalTheme.hand(
                                      fontSize: 22,
                                      color: ArtisanalTheme.ink,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recipe.description ?? '',
                                    style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.7)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildInfoItem(Icons.layers, '${l10n.yieldLabel}: ${recipe.components.length} parts'),
                                      const SizedBox(width: 16),
                                      _buildInfoItem(Icons.schedule, '${l10n.timeLabel}: ~4h'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? ArtisanalTheme.ink : Colors.transparent,
        border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: ArtisanalTheme.hand(
          fontSize: 18,
          color: isSelected ? Colors.white : ArtisanalTheme.ink,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: ArtisanalTheme.outline),
        const SizedBox(width: 4),
        Text(
          label,
          style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.outline),
        ),
      ],
    );
  }
}
