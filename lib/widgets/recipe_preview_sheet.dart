import 'package:flutter/material.dart';
import '../theme/artisanal_theme.dart';
import '../screens/add_recipe_screen.dart';
import '../widgets/artisanal_image.dart';

class RecipePreviewSheet extends StatelessWidget {
  final RecipeDraft draft;

  const RecipePreviewSheet({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F3F0),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 100),
            child: Column(
              children: [
                _JournalPagePreview(draft: draft),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: ArtisanalTheme.ink,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalPagePreview extends StatelessWidget {
  final RecipeDraft draft;
  const _JournalPagePreview({required this.draft});

  @override
  Widget build(BuildContext context) {
    final title = draft.name.isEmpty ? "Untitled Recipe" : draft.name;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Binder Detail
          Container(
            width: 24,
            height: 1200 + (draft.components.length * 300),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDAD6CF), Color(0xFFE8E4DC)],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Transform.rotate(
                      angle: -0.015,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: ArtisanalTheme.hand(
                          fontSize: 40,
                          color: ArtisanalTheme.ink,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Main Photo
                  if (draft.mainImagePath != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        color: Colors.white,
                        child: SizedBox(
                          width: 300,
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: ArtisanalImage(
                              imagePath: draft.mainImagePath!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 48),

                  // Components Preview
                  ...draft.components.map((comp) => _ComponentPreview(component: comp)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentPreview extends StatelessWidget {
  final RecipeComponent component;
  const _ComponentPreview({required this.component});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            component.title.toUpperCase(),
            style: ArtisanalTheme.hand(fontSize: 22, color: ArtisanalTheme.primary).copyWith(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 12),
          // Ingredients
          ...component.ingredients.map((ing) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text("• ${ing.name}", style: ArtisanalTheme.hand(fontSize: 17, color: ArtisanalTheme.ink)),
                const Spacer(),
                Text("${ing.weight.toStringAsFixed(0)}g", style: ArtisanalTheme.hand(fontSize: 17, color: ArtisanalTheme.ink)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          // Steps
          ...component.steps.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${entry.key + 1}. ", style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.secondary)),
                Expanded(
                  child: Text(
                    entry.value.content,
                    style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.ink),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
