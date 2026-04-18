import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/artisanal_image.dart';
import '../widgets/masking_tape.dart';
import '../models/recipe.dart';

class SummaryNoteScreen extends StatelessWidget {
  final Recipe? recipe;

  const SummaryNoteScreen({super.key, this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ArtisanalTheme.ink),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: _JournalPage(recipe: recipe),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalPage extends StatelessWidget {
  final Recipe? recipe;
  const _JournalPage({this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final title = recipe?.name ?? 'Pumpkin Porridge Dessert';
    final mainImage = recipe?.mainImageUrl ?? 'assets/images/pumpkin_dessert.png';
    final components = recipe?.components ?? [];

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
            height: 2500, // Sufficiently long
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFDAD6CF), Color(0xFFE8E4DC)],
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
                  padding: const EdgeInsets.fromLTRB(40, 48, 40, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          l10n.summaryDate,
                          style: ArtisanalTheme.hand(
                            fontSize: 18,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Center(
                        child: Transform.rotate(
                          angle: -0.015,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: ArtisanalTheme.hand(fontSize: 48, color: ArtisanalTheme.ink).copyWith(fontWeight: FontWeight.bold, height: 1.1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Hero Image
                      Center(
                        child: Transform.rotate(
                          angle: 0.017,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
                              ],
                              border: Border.all(color: Colors.white, width: 8),
                            ),
                            child: SizedBox(
                              width: 380,
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: ArtisanalImage(imagePath: mainImage, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),

                      // Render Dynamic Components
                      ...components.map((comp) => _RecipeSection(
                        title: comp.title,
                        imagePath: comp.imageUrl,
                        ingredients: comp.ingredients.map((i) => (i.name, "${i.amount}${i.unit}")).toList(),
                        steps: comp.steps.map((s) => s.description).toList(),
                      )),
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
  final String? imagePath;
  final List<(String, String)> ingredients;
  final List<String> steps;

  const _RecipeSection({
    required this.title,
    this.imagePath,
    required this.ingredients,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    const ink = ArtisanalTheme.ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Title + Optional Photo
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: ArtisanalTheme.hand(fontSize: 28, color: ink).copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            if (imagePath != null && imagePath!.isNotEmpty) ...[
              const SizedBox(width: 16),
              Transform.rotate(
                angle: 0.05,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(2, 2)),
                        ],
                      ),
                      child: SizedBox(
                        width: 110,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ArtisanalImage(imagePath: imagePath!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: -10,
                      child: MaskingTape(width: 60),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        
        // Body: Ingredients & Steps (Full Width)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ingredients
            ...ingredients.map((ing) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text('• ${ing.$1}', style: ArtisanalTheme.hand(fontSize: 19, color: ink)),
                  const Spacer(),
                  Text(ing.$2, style: ArtisanalTheme.hand(fontSize: 19, color: ink)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            // Steps
            ...steps.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.key + 1}. ', style: ArtisanalTheme.hand(fontSize: 18, color: ink.withValues(alpha: 0.6))),
                  Expanded(child: Text(entry.value, style: ArtisanalTheme.hand(fontSize: 18, color: ink))),
                ],
              ),
            )),
          ],
        ),
        const SizedBox(height: 60),
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
