import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/polaroid_card.dart';
import '../widgets/torn_edge_clipper.dart';
import 'recipe_detail_screen.dart';

class RecipeArchiveScreen extends StatelessWidget {
  const RecipeArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'R&D Archive',
                      style: ArtisanalTheme.hand(
                        fontSize: 20,
                        color: ArtisanalTheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'My Recipes',
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
                  _buildFilterChip('#Vegan', isSelected: true),
                  _buildFilterChip('#LargeBatch'),
                  _buildFilterChip('#SlowFerment'),
                  _buildFilterChip('#Sourdough'),
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
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final recipes = [
                  {
                    'title': 'Spelt & Honey Sourdough',
                    'desc': '80% Hydration, 12hr cold bulk ferment',
                    'yield': '2 Loaves',
                    'time': '18 Hours',
                    'temp': '68°F',
                    'img': 'https://images.unsplash.com/photo-1509440159596-dec2190391d2?q=80&w=400'
                  },
                  {
                    'title': 'Classic French Baguette',
                    'desc': 'Poolish based, steam injected bake',
                    'yield': '4 Sticks',
                    'time': '5 Hours',
                    'temp': '74°F',
                    'img': 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?q=80&w=400'
                  },
                  {
                    'title': 'Rosemary Olive Oil Cake',
                    'desc': 'Sicilian cold-pressed oil, flaky sea salt',
                    'yield': '10" Pan',
                    'time': '1.5 Hours',
                    'temp': '65°F',
                    'img': 'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?q=80&w=400'
                  },
                  {
                    'title': 'Brown Butter Cookies',
                    'desc': '70% Dark chocolate, toasted hazelnuts',
                    'yield': '24 Pieces',
                    'time': '45 Minutes',
                    'temp': '78°F',
                    'img': 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?q=80&w=400'
                  },
                ];

                final recipe = recipes[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          title: recipe['title']!,
                          imageUrl: recipe['img']!,
                        ),
                      ),
                    );
                  },
                  child: TornEdgeContainer(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                              recipe['img']!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                            ),
                              const Positioned(
                                top: 4,
                                left: 4,
                                child: WashiTape(width: 30, height: 10, rotation: 0.1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      recipe['title']!,
                                      style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 18),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ArtisanalTheme.background,
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.cloud, size: 12, color: ArtisanalTheme.ink),
                                        const SizedBox(width: 4),
                                        Text(recipe['temp']!, style: ArtisanalTheme.hand(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recipe['desc']!,
                                style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.ink.withValues(alpha: 0.7)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildInfoItem(Icons.layers, recipe['yield']!),
                                  const SizedBox(width: 16),
                                  _buildInfoItem(Icons.schedule, recipe['time']!),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? ArtisanalTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        style: ArtisanalTheme.hand(
          fontSize: 18,
          color: isSelected ? Colors.white : ArtisanalTheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ArtisanalTheme.ink),
        const SizedBox(width: 6),
        Text(
          label,
          style: ArtisanalTheme.hand(fontSize: 14, color: ArtisanalTheme.ink),
        ),
      ],
    );
  }
}
