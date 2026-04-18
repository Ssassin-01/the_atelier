import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/polaroid_card.dart';
import 'recipe_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'Journal No. 42',
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
                      'Find your\nperfect recipe',
                      style: ArtisanalTheme.lightTheme.textTheme.displayLarge?.copyWith(
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What are we baking today?',
                      style: ArtisanalTheme.hand(
                        fontSize: 32,
                        color: ArtisanalTheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Search Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ArtisanalTheme.outline.withValues(alpha: 0.3),
                    width: 2,
                    style: BorderStyle.solid, // Should be dotted if possible, but solid for simplicity now
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: ArtisanalTheme.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search doughs, techniques...',
                        hintStyle: ArtisanalTheme.hand(
                          fontSize: 24,
                          color: ArtisanalTheme.outline.withAlpha((0.5 * 255).toInt()),
                        ),
                        border: InputBorder.none,
                      ),
                      style: ArtisanalTheme.hand(fontSize: 24, color: ArtisanalTheme.ink),
                    ),
                  ),
                  const Icon(Icons.auto_stories, color: ArtisanalTheme.outline),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Recent R&D
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Recent R&D',
                  style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 24),
                ),
                Row(
                  children: [
                    Text(
                      'View Lab',
                      style: ArtisanalTheme.hand(fontSize: 20, color: ArtisanalTheme.primary),
                    ),
                    const Icon(Icons.arrow_right_alt, color: ArtisanalTheme.primary, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeDetailScreen(
                            title: 'Honey-Butter Croissant',
                            imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=400&auto=format&fit=crop',
                          ),
                        ),
                      );
                    },
                    child: PolaroidCard(
                      rotation: -0.03,
                      title: 'Honey-Butter Croissant',
                      subtitle: 'Feb 14 Lamination Test',
                      image: Image.network(
                        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=600',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeDetailScreen(
                            title: 'Lavender Madeleine',
                            imageUrl: 'https://images.unsplash.com/photo-1549419163-9426f4974f76?q=80&w=400&auto=format&fit=crop',
                          ),
                        ),
                      );
                    },
                    child: PolaroidCard(
                      rotation: 0.04,
                      tapeColor: ArtisanalTheme.primary.withAlpha((0.2 * 255).toInt()),
                      title: 'Lavender Madeleine',
                      subtitle: 'Feb 12 ??Floral Infusion',
                      image: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDllbnw96jDsqz1WAohJ2Wxkup4u5imOZIkhoNNlggGow_gHpdpVpoXrzdwiOXnoDLyC7EOPfaMxHa1QrZgR_2unUrUvIlFcqPL6ePL0vyQZ-bFJ6RcVf-1qWCkL24BF2x_qQejDLUlg1A9Q-3SuOSlhIMGyURdR826Lyb5o942-FWQfktbHsotLLd3EikMVCT_rXuVLRdul6BP0RAxCcUKWS6ppM4TtI4nRLVU3RRpImOeyeLNyBjDigLIQn4jU666fZeBrIMV-6M',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeDetailScreen(
                            title: 'Heritage Sourdough',
                            imageUrl: 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?q=80&w=400&auto=format&fit=crop',
                          ),
                        ),
                      );
                    },
                    child: PolaroidCard(
                      rotation: -0.05,
                      tapeColor: Colors.black12,
                      title: 'Heritage Sourdough',
                      subtitle: 'Feb 10 ??80% Hydration',
                      image: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDyx-s-5_bMiOPXczyE5MBVC8AeMUPDCSmSBsl2K9e40nluqNHFKYm2_c7fdArOEZ4is6cr5vXFQSNUWLAyhobGVDxolrj3nDxjaDJr2cUCa17itH1Jb_pAuVQShztKqA8Nf6I4E0JI8dS2AOBLhT9UDtITOKFRHqHKPTySAxPzGp9kaZZ_OLLiAqxW6xfaCLfG0ZeYnCutd8sy-Hsv7URYYJ1fWYJuL5DyNmOWvJItYmAS23DQdftWtxpTNl53ZYUp5wNFXgLGCvs',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Collections
            Text(
              'Collections',
              style: ArtisanalTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 4 / 3,
              children: const [
                CollectionCard(volume: 'Vol. I', title: 'Breads', icon: Icons.bakery_dining),
                CollectionCard(volume: 'Vol. II', title: 'Cakes', icon: Icons.cake),
                CollectionCard(volume: 'Vol. III', title: 'Cookies', icon: Icons.cookie),
                CollectionCard(volume: 'Vol. IV', title: 'Tarts', icon: Icons.pie_chart),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class CollectionCard extends StatelessWidget {
  final String volume;
  final String title;
  final IconData icon;

  const CollectionCard({
    super.key,
    required this.volume,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(icon, color: ArtisanalTheme.ink.withValues(alpha: 0.8), size: 36),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  volume,
                  style: ArtisanalTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: Colors.black38,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  title,
                  style: ArtisanalTheme.hand(fontSize: 28, color: ArtisanalTheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
