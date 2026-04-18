import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/polaroid_card.dart';

import 'summary_note_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;

  const RecipeDetailScreen({
    super.key,
    this.title = 'Pumpkin Porridge Dessert',
    this.imageUrl = 'https://images.unsplash.com/photo-1509440159596-dec2190391d2?q=80&w=800',
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ArtisanalTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 600,
            floating: false,
            pinned: true,
            backgroundColor: ArtisanalTheme.background,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: ArtisanalTheme.primary)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: availableHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(
                                fontSize: availableHeight < 500 ? 32 : 40,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              const WashiTape(width: 100, rotation: -0.05),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: PolaroidCard(
                                  width: availableHeight < 500 ? 220 : 280,
                                  image: Image.network(
                                    imageUrl, 
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                                  ),
                                  title: l10n.autumnMenu24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTornTabs(context),
                const SizedBox(height: 48),
                _buildPostItComponent(l10n, l10n.pumpkinPureeBaseTitle, [
                  _ingredientRow(l10n.ingredientKabochaSquash, '500g'),
                  _ingredientRow(l10n.ingredientWholeMilk, '200g'),
                  _ingredientRow(l10n.ingredientHeavyCream, '150g'),
                  _ingredientRow(l10n.ingredientBrownSugar, '60g'),
                ]),
                const SizedBox(height: 32),
                _buildPostItComponent(l10n, l10n.miniRiceBallsTitle, [
                  _ingredientRow(l10n.ingredientGlutinousFlour, '100g'),
                  _ingredientRow(l10n.ingredientWarmWater, '80g'),
                  _ingredientRow(l10n.ingredientSugar, '10g'),
                ], rotation: 0.02),
                const SizedBox(height: 60),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SummaryNoteScreen()),
                      );
                    },
                    icon: const Icon(Icons.menu_book),
                    label: Text(l10n.openJournalSummary),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ArtisanalTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: ArtisanalTheme.hand(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTornTabs(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [l10n.all, l10n.pumpkinPuree, l10n.miniRiceBalls, l10n.seedTuile];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = tab == l10n.all;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? ArtisanalTheme.primary : ArtisanalTheme.background,
              border: Border.all(color: ArtisanalTheme.primary.withValues(alpha: 0.3)),
              boxShadow: [
                if (isSelected) BoxShadow(color: ArtisanalTheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Text(
              tab.toUpperCase(),
              style: ArtisanalTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : ArtisanalTheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostItComponent(AppLocalizations l10n, String title, List<Widget> ingredients, {double rotation = -0.02}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(2, 4))],
          border: Border.all(color: ArtisanalTheme.ink.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: ArtisanalTheme.hand(fontSize: 28, color: ArtisanalTheme.ink).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(height: 2, color: ArtisanalTheme.ink.withValues(alpha: 0.1), width: 100),
            const SizedBox(height: 24),
            ...ingredients,
            const SizedBox(height: 24),
            _buildActionHint(l10n.jumpToProcedure),
          ],
        ),
      ),
    );
  }

  Widget _ingredientRow(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.ink)),
          Text(amount, style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.ink)),
        ],
      ),
    );
  }

  Widget _buildActionHint(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.arrow_downward, size: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(text, style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.5))),
      ],
    );
  }
}
