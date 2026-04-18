import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/artisanal_image.dart';

class SummaryNoteScreen extends StatelessWidget {
  const SummaryNoteScreen({super.key});

  static const Color _ink = Color(0xFF4A3B32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _ink),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: _JournalPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left leather binding
          Container(
            width: 32,
            height: 1800, // Long enough for content
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFDAD6CF), Color(0xFFE8E4DC)],
              ),
              border: Border(
                right: BorderSide(color: Colors.black.withValues(alpha: 0.08), width: 1),
              ),
            ),
          ),
          // Page content
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _RuledLinePainter()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 48, 40, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date & Version
                      Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.summaryDate,
                              style: ArtisanalTheme.hand(
                                fontSize: 20,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                            ),
                            Text(
                              l10n.summaryVersion,
                              style: ArtisanalTheme.hand(
                                fontSize: 18,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Center(
                        child: Transform.rotate(
                          angle: -0.018,
                          child: Text(
                            'Pumpkin Porridge Dessert',
                            textAlign: TextAlign.center,
                            style: ArtisanalTheme.hand(
                              fontSize: 52,
                              color: const Color(0xFF4A3B32),
                            ).copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Hero Image
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Transform.rotate(
                              angle: 0.017,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white, width: 8),
                                ),
                                child: const SizedBox(
                                  width: 420,
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: ArtisanalImage(
                                      imagePath: 'assets/images/pumpkin_dessert.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -28,
                              right: 0,
                              child: Transform.rotate(
                                angle: -0.04,
                                child: Text(
                                  '* final plating idea',
                                  style: ArtisanalTheme.hand(
                                    fontSize: 20,
                                    color: const Color(0xFF4A3B32).withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                      // Sections
                      _RecipeSection(
                        title: 'A. Pumpkin Cream',
                        ingredients: [
                          ('Frozen Kabocha', '300g'),
                          ('Milk', '90g'),
                          ('Heavy Cream', '60g'),
                          ('Egg Yolks', '22g'),
                          ('Sugar', '15g'),
                          ('Sheet Gelatin', '2g'),
                        ],
                        steps: [
                          'Steam kabocha (170°C for 20m) & puree.',
                          'Heat milk and cream together.',
                          'Whisk yolks, sugar, salt. Heat mix to 82°C.',
                          'Emulsify with gelatin and fold in puree.',
                        ],
                      ),
                      const SizedBox(height: 48),
                      _RecipeSection(
                        title: 'B. Mini Rice Balls',
                        ingredients: [
                          ('Glutinous Rice Flour', '50g'),
                          ('Hot Water', '32g'),
                          ('Sugar', '4g'),
                        ],
                        steps: [
                          'Mix dry ingredients. Add hot water for dough.',
                          'Shape into 4g spheres. Boil until they float.',
                          'Chill immediately in ice water.',
                        ],
                      ),
                      const SizedBox(height: 48),
                      _RecipeSection(
                        title: 'C. Pumpkin Seed Tuile',
                        ingredients: [
                          ('Pumpkin Seeds', '50g'),
                          ('Butter', '35g'),
                          ('Icing Sugar', '35g'),
                          ('Rice Flour', '15g'),
                          ('Egg White', '30g'),
                        ],
                        steps: [
                          'Chop seeds. Mix butter and icing sugar.',
                          'Add egg white and flour. Fold in seeds.',
                          'Rest 20m. Bake at 180°C for 8-11m.',
                        ],
                      ),
                      const SizedBox(height: 48),
                      _RecipeSection(
                        title: 'D. Soybean Rice Crumble',
                        ingredients: [
                          ('Rice Flour', '35g'),
                          ('Soybean Powder', '20g'),
                          ('Almond Flour', '15g'),
                          ('Butter', '32g'),
                        ],
                        steps: [
                          'Sift powders. Rub in cold cubed butter.',
                          'Freeze briefly. Bake at 160°C for 12-15m.',
                          'Cool and crumble by hand.',
                        ],
                      ),
                      const SizedBox(height: 48),
                      _RecipeSection(
                        title: 'E. Rice Ice Cream',
                        ingredients: [
                          ('Glutinous Rice', '50g'),
                          ('Milk', '350g'),
                          ('Heavy Cream', '84g'),
                          ('Glucose/Sugar', '60g'),
                          ('Roasted Rice', '7g'),
                        ],
                        steps: [
                          'Simmer rice and milk. Add cream.',
                          'Heat to 82°C and blend until smooth.',
                          'Fold in roasted rice and churn.',
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  final String title;
  final List<(String, String)> ingredients;
  final List<String> steps;

  const _RecipeSection({
    required this.title,
    required this.ingredients,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF4A3B32);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ArtisanalTheme.hand(
            fontSize: 28,
            color: ink,
          ).copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
        ),
        const SizedBox(height: 16),
        // Ingredients List (Vertical)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ingredients.map((ing) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              '• ${ing.$1}: ${ing.$2}',
              style: ArtisanalTheme.hand(fontSize: 19, color: ink.withValues(alpha: 0.85)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        // Steps List (Below Ingredients)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steps.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key + 1}. ',
                  style: ArtisanalTheme.hand(fontSize: 18, color: ink.withValues(alpha: 0.6)),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: ArtisanalTheme.hand(fontSize: 18, color: ink),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _RuledLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E0D8)
      ..strokeWidth = 1.0;

    const double lineSpacing = 30.0;
    for (double y = 140; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
