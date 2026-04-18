import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/masking_tape.dart';
import '../widgets/recipe_preview_sheet.dart';
import 'full_screen_sketch_editor.dart';

// ── Data Models ─────────────────────────────────────────────────────────────
class IngredientEntry {
  final String id;
  String name;
  double weight;
  bool isFlour;

  IngredientEntry({
    required this.id,
    this.name = '',
    this.weight = 0,
    this.isFlour = false,
  });
}

class RecipeStep {
  final String id;
  String content;
  RecipeStep({required this.id, this.content = ''});
}

class RecipeComponent {
  final String id;
  String title;
  String? imagePath;
  List<IngredientEntry> ingredients;
  List<RecipeStep> steps;

  RecipeComponent({
    required this.id,
    this.title = 'New Component',
    this.imagePath,
    List<IngredientEntry>? ingredients,
    List<RecipeStep>? steps,
  }) : ingredients = ingredients ?? [],
       steps = steps ?? [RecipeStep(id: 's1')];

  double get totalFlour => ingredients
      .where((e) => e.isFlour)
      .fold(0.0, (sum, e) => sum + e.weight);

  double get totalWeight => ingredients.fold(0.0, (sum, e) => sum + e.weight);
}

class RecipeDraft {
  String name;
  String? mainImagePath;
  List<RecipeComponent> components;
  
  RecipeDraft({
    this.name = '',
    this.mainImagePath,
    List<RecipeComponent>? components,
  }) : components = components ?? [
    RecipeComponent(id: 'c1', title: 'Main Dough', ingredients: [
      IngredientEntry(id: 'i1', name: 'Bread Flour', weight: 500, isFlour: true),
      IngredientEntry(id: 'i2', name: 'Water', weight: 350),
    ])
  ];

  double get totalWeight => components.fold(0.0, (sum, c) => sum + c.totalWeight);
}

final recipeDraftProvider = StateProvider.autoDispose<RecipeDraft>((ref) => RecipeDraft());

class AddRecipeScreen extends ConsumerWidget {
  final VoidCallback? onBack;
  const AddRecipeScreen({super.key, this.onBack});

  void _triggerFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(recipeDraftProvider);
    final notifier = ref.read(recipeDraftProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: const Icon(Icons.close, color: ArtisanalTheme.ink),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              l10n.atelierNotebook.toUpperCase(),
              style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.secondary, letterSpacing: 2),
            ),
            actions: [
              IconButton(
                padding: const EdgeInsets.only(right: 8),
                icon: const Icon(Icons.auto_stories_outlined, color: ArtisanalTheme.primary),
                tooltip: "Preview in Journal",
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      builder: (_, controller) => RecipePreviewSheet(draft: draft),
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () {},
                child: Text('SAVE', style: ArtisanalTheme.hand(fontSize: 18, color: ArtisanalTheme.primary)),
              ),
              const SizedBox(width: 16),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                
                // ── Photo Selector with Tape ────────────────────────────────
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: _buildPhotoSelector(context, draft.mainImagePath, (path) {
                        notifier.update((s) => RecipeDraft(name: s.name, mainImagePath: path, components: s.components));
                      }, height: 280, label: "Add Cover Media"),
                    ),
                    const MaskingTape(width: 140, label: "MAIN VIEW"),
                  ],
                ),

                const SizedBox(height: 32),
                
                TextField(
                  onChanged: (val) {
                    _triggerFeedback();
                    notifier.update((s) => RecipeDraft(name: val, mainImagePath: s.mainImagePath, components: s.components));
                  },
                  decoration: InputDecoration(
                    hintText: l10n.recipeNameHint,
                    hintStyle: GoogleFonts.notoSerif(
                        fontSize: 34,
                        fontStyle: FontStyle.italic,
                        color: ArtisanalTheme.ink.withValues(alpha: 0.1)),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: ArtisanalTheme.primary, width: 2),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1),
                    ),
                  ),
                  style: GoogleFonts.notoSerif(
                      fontSize: 34,
                      fontStyle: FontStyle.italic,
                      color: ArtisanalTheme.ink),
                ),

                const SizedBox(height: 48),

                // ── Summary Row (Subtle) ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("EST. WEIGHT:", style: ArtisanalTheme.hand(fontSize: 12, color: ArtisanalTheme.secondary)),
                    const SizedBox(width: 8),
                    Text("${draft.totalWeight.toStringAsFixed(0)}G", style: GoogleFonts.notoSerif(fontSize: 14, fontWeight: FontWeight.bold, color: ArtisanalTheme.secondary)),
                  ],
                ),
                const SizedBox(height: 24),

                ...draft.components.asMap().entries.map((entry) => _buildComponentSection(context, ref, entry.value, entry.key)),

                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _triggerFeedback();
                      notifier.update((s) {
                        final newComps = List<RecipeComponent>.from(s.components)
                          ..add(RecipeComponent(id: DateTime.now().toString()));
                        return RecipeDraft(name: s.name, mainImagePath: s.mainImagePath, components: newComps);
                      });
                    },
                    icon: const Icon(Icons.library_add_outlined),
                    label: Text("ADD ANOTHER COMPONENT",
                        style: ArtisanalTheme.hand(fontSize: 18)),
                    style: TextButton.styleFrom(
                      foregroundColor: ArtisanalTheme.secondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      side: BorderSide(
                          color: ArtisanalTheme.secondary.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSelector(
      BuildContext context, String? path, Function(String?) onSelected,
      {double height = 200,
      String label = "Add Photo",
      bool fullWidth = true}) {
    return Center(
      child: GestureDetector(
        onTap: () {}, // Image picker placeholder
        child: Container(
          width: fullWidth ? double.infinity : 260,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white, // Polaroid white border
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 15,
                  offset: const Offset(5, 8)),
            ],
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Polaroid bottom padding
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: path == null
                            ? Container(
                                color: const Color(0xFFF2EFED),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined,
                                        color: ArtisanalTheme.outline
                                            .withValues(alpha: 0.3),
                                        size: 32),
                                    const SizedBox(height: 8),
                                    Text(label,
                                        style: ArtisanalTheme.hand(
                                            fontSize: 14,
                                            color: ArtisanalTheme.outline
                                                .withValues(alpha: 0.5))),
                                  ],
                                ),
                              )
                            : Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
                      // Action Overlay when empty
                      if (path == null)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _mediaActionBtn(Icons.photo_library, () {}),
                                const SizedBox(width: 8),
                                _mediaActionBtn(Icons.brush, () async {
                                  final sketchPath =
                                      await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const FullScreenSketchEditor()),
                                  );
                                  if (sketchPath != null) {
                                    onSelected(sketchPath);
                                  }
                                }),
                              ],
                            ),
                          ),
                        ),
                      if (path != null)
                         Positioned(
                           top: 4,
                           right: 4,
                           child: _mediaActionBtn(Icons.close, () => onSelected(null), isSmall: true),
                         ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  path != null && path.contains('sketch') ? "Hand-drawn sketch" : "Snap of the day",
                  style: ArtisanalTheme.hand(
                      fontSize: 12, color: Colors.black26),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mediaActionBtn(IconData icon, VoidCallback onTap, {bool isSmall = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 4 : 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: isSmall ? 14 : 20),
      ),
    );
  }

  Widget _buildComponentSection(
      BuildContext context, WidgetRef ref, RecipeComponent component, int index) {
    final notifier = ref.read(recipeDraftProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF9F3), // Linen Beige background instead of white
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: ArtisanalTheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: index % 2 == 0 ? 0.005 : -0.005,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      _triggerFeedback();
                      component.title = val;
                    },
                    controller: TextEditingController(text: component.title)..selection = TextSelection.collapsed(offset: component.title.length),
                    style: ArtisanalTheme.hand(
                        fontSize: 22, color: ArtisanalTheme.primary),
                    decoration: const InputDecoration(
                      hintText: "Component Name...",
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: ArtisanalTheme.primary, width: 1),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12, width: 1),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_photo_alternate_outlined, size: 20, color: component.imagePath == null ? ArtisanalTheme.outline : ArtisanalTheme.primary),
                  onPressed: () {
                    _triggerFeedback();
                    notifier.update((s) {
                      component.imagePath = component.imagePath == null ? 'placeholder' : null;
                      return RecipeDraft(name: s.name, mainImagePath: s.mainImagePath, components: s.components);
                    });
                  },
                ),
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: ArtisanalTheme.redInk),
                    onPressed: () {
                      _triggerFeedback();
                      notifier.update((s) {
                        final newComps = List<RecipeComponent>.from(s.components)..removeAt(index);
                        return RecipeDraft(name: s.name, mainImagePath: s.mainImagePath, components: newComps);
                      });
                    },
                  ),
              ],
            ),
            const Divider(height: 1, color: ArtisanalTheme.outline),
            const SizedBox(height: 20),
            Column(
              children: [
                ...component.ingredients.asMap().entries.map((entry) =>
                    _buildIngredientRow(ref, component, entry.value, entry.key)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      _triggerFeedback();
                      notifier.update((s) {
                        component.ingredients.add(IngredientEntry(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString()));
                        return RecipeDraft(
                            name: s.name,
                            mainImagePath: s.mainImagePath,
                            components: s.components);
                      });
                    },
                    icon: const Icon(Icons.add, size: 14),
                    label: Text("Add Ingredient",
                        style: ArtisanalTheme.hand(fontSize: 14)),
                    style: TextButton.styleFrom(
                      foregroundColor: ArtisanalTheme.secondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      side: BorderSide(
                          color: ArtisanalTheme.secondary.withValues(alpha: 0.1)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text("PROCESS FOR THIS PART", style: ArtisanalTheme.hand(fontSize: 11, color: ArtisanalTheme.secondary, letterSpacing: 1)),
            const SizedBox(height: 12),
            ...component.steps.asMap().entries.map((stepEntry) => _buildStepRow(ref, component, stepEntry.value, stepEntry.key)),
            TextButton.icon(
              onPressed: () {
                _triggerFeedback();
                notifier.update((s) {
                  component.steps.add(RecipeStep(id: DateTime.now().toString()));
                  return RecipeDraft(name: s.name, mainImagePath: s.mainImagePath, components: s.components);
                });
              },
              icon: const Icon(Icons.add, size: 14),
              label: Text("Add Process Step",
                  style: ArtisanalTheme.hand(fontSize: 14)),
              style: TextButton.styleFrom(
                foregroundColor: ArtisanalTheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                side: BorderSide(
                    color: ArtisanalTheme.secondary.withValues(alpha: 0.1)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            if (component.imagePath != null) ...[
              const SizedBox(height: 48),
              Center(
                child: SizedBox(
                  width: 260,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildPhotoSelector(
                        context,
                        component.imagePath == 'placeholder'
                            ? null
                            : component.imagePath,
                        (path) {
                          _triggerFeedback();
                          notifier.update((s) {
                            component.imagePath = path;
                            return RecipeDraft(
                                name: s.name,
                                mainImagePath: s.mainImagePath,
                                components: s.components);
                          });
                        },
                        height: 280,
                        label: "Snap or Sketch",
                        fullWidth: true,
                      ),
                      const Positioned(
                        top: -15,
                        left: 80,
                        right: 80,
                        child: MaskingTape(width: 100),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(WidgetRef ref, RecipeComponent component, IngredientEntry entry, int index) {
    final notifier = ref.read(recipeDraftProvider.notifier);
    final totalFlour = component.totalFlour;
    final percentage = (totalFlour > 0) ? (entry.weight / totalFlour) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to top for predictable baseline
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0), // Align icon with text
            child: GestureDetector(
              onTap: () {
                _triggerFeedback();
                notifier.update((s) {
                  entry.isFlour = !entry.isFlour;
                  return RecipeDraft(
                      name: s.name,
                      mainImagePath: s.mainImagePath,
                      components: s.components);
                });
              },
              child: Icon(
                Icons.grass_outlined,
                size: 16,
                color: entry.isFlour
                    ? ArtisanalTheme.primary
                    : ArtisanalTheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (val) {
                    _triggerFeedback();
                    entry.name = val;
                  },
                  controller: TextEditingController(text: entry.name)
                    ..selection =
                        TextSelection.collapsed(offset: entry.name.length),
                  style: ArtisanalTheme.hand(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: "Ingredient name...",
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: ArtisanalTheme.primary, width: 1.5),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1.0),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                // Mirror the height of percentage text to keep underlines aligned
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  onChanged: (val) {
                    _triggerFeedback();
                    notifier.update((s) {
                      entry.weight = double.tryParse(val) ?? 0;
                      return RecipeDraft(
                          name: s.name,
                          mainImagePath: s.mainImagePath,
                          components: s.components);
                    });
                  },
                  style: GoogleFonts.notoSerif(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "0",
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: ArtisanalTheme.primary, width: 1.5),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1.0),
                    ),
                    suffixText: "g",
                    suffixStyle: TextStyle(fontSize: 12, color: Colors.black38),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                if (entry.weight > 0 && totalFlour > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: entry.isFlour
                            ? ArtisanalTheme.primary.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: ArtisanalTheme.hand(
                          fontSize: 10,
                          fontWeight:
                              entry.isFlour ? FontWeight.bold : FontWeight.normal,
                          color: entry.isFlour
                              ? ArtisanalTheme.primary
                              : ArtisanalTheme.ink.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                else if (totalFlour > 0)
                  const SizedBox(height: 19) // Consistent spacing
                else
                  const SizedBox(height: 19),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 10.0), // Match icon with top text
            child: GestureDetector(
              onTap: () {
                _triggerFeedback();
                notifier.update((s) {
                  component.ingredients.removeAt(index);
                  return RecipeDraft(
                      name: s.name,
                      mainImagePath: s.mainImagePath,
                      components: s.components);
                });
              },
              child: const Icon(Icons.close,
                  size: 16, color: ArtisanalTheme.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(WidgetRef ref, RecipeComponent component, RecipeStep step, int index) {
    final notifier = ref.read(recipeDraftProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text("${index + 1}.", style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.secondary)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (val) {
                 _triggerFeedback();
                 step.content = val;
              },
              maxLines: null,
              style:
                  ArtisanalTheme.hand(fontSize: 17, color: ArtisanalTheme.ink),
              decoration: const InputDecoration(
                hintText: "Write process step here...",
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 0.5),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: ArtisanalTheme.primary, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 0.5),
                ),
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove, size: 14, color: ArtisanalTheme.outline),
            onPressed: () {
              _triggerFeedback();
              notifier.update((s) {
                component.steps.removeAt(index);
                return RecipeDraft(name: s.name, mainImagePath: s.mainImagePath, components: s.components);
              });
            },
          ),
        ],
      ),
    );
  }
}
