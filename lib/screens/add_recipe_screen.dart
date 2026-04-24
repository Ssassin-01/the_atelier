import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../theme/artisanal_theme.dart';
import '../widgets/masking_tape.dart';
import '../widgets/recipe_preview_sheet.dart';
import 'full_screen_sketch_editor.dart';
import '../models/recipe.dart' as model;
import '../models/component.dart' as model;
import '../models/ingredient.dart' as model;
import '../models/step.dart' as model;
import '../widgets/artisanal_image.dart';
import '../services/recipe_service.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';

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

class RecipeStepDraft {
  final String id;
  String content;
  RecipeStepDraft({required this.id, this.content = ''});
}

class RecipeComponentDraft {
  final String id;
  String title;
  String? imagePath;
  List<IngredientEntry> ingredients;
  List<RecipeStepDraft> steps;

  RecipeComponentDraft({
    required this.id,
    this.title = 'New Component',
    this.imagePath,
    List<IngredientEntry>? ingredients,
    List<RecipeStepDraft>? steps,
  }) : ingredients = ingredients ?? [],
       steps = steps ?? [RecipeStepDraft(id: 's1')];

  double get totalFlour => ingredients
      .where((e) => e.isFlour)
      .fold(0.0, (sum, e) => sum + e.weight);

  double get totalWeight => ingredients.fold(0.0, (sum, e) => sum + e.weight);
}

class RecipeDraft {
  String name;
  String? mainImagePath;
  List<RecipeComponentDraft> components;
  
  RecipeDraft({
    this.name = '',
    this.mainImagePath,
    List<RecipeComponentDraft>? components,
  }) : components = components ?? [
    RecipeComponentDraft(id: 'c1', title: 'Main Dough', ingredients: [
      IngredientEntry(id: 'i1', name: 'Bread Flour', weight: 500, isFlour: true),
      IngredientEntry(id: 'i2', name: 'Water', weight: 350),
    ])
  ];

  double get totalWeight => components.fold(0.0, (sum, c) => sum + c.totalWeight);

  static RecipeDraft fromModel(model.Recipe recipe) {
    return RecipeDraft(
      name: recipe.name,
      mainImagePath: recipe.mainImageUrl,
      components: recipe.components.map((c) => RecipeComponentDraft(
        id: DateTime.now().millisecondsSinceEpoch.toString() + c.title,
        title: c.title,
        imagePath: c.imageUrl,
        ingredients: c.ingredients.map((i) => IngredientEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.name,
          name: i.name,
          weight: double.tryParse(i.amount) ?? 0,
          isFlour: i.isFlour, 
        )).toList(),
        steps: c.steps.map((s) => RecipeStepDraft(
          id: DateTime.now().millisecondsSinceEpoch.toString() + s.description.substring(0, math.min(5, s.description.length)),
          content: s.description,
        )).toList(),
      )).toList(),
    );
  }
}

final recipeDraftProvider = StateProvider.autoDispose<RecipeDraft>((ref) => RecipeDraft());

class AddRecipeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final String? editingRecipeId;
  const AddRecipeScreen({super.key, this.onBack, this.editingRecipeId});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  void _triggerFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  void initState() {
    super.initState();
    if (widget.editingRecipeId != null) {
      // Defer state update to next frame to avoid build-phase exceptions
      Future.microtask(() {
        final recipes = ref.read(recipeListProvider);
        final existing = recipes.where((r) => r.id == widget.editingRecipeId).firstOrNull;
        if (existing != null) {
          ref.read(recipeDraftProvider.notifier).state = RecipeDraft.fromModel(existing);
        }
      });
    } else {
      // CLEAR DRAFT for new recipe to avoid bug where last edited recipe remains
      Future.microtask(() {
        ref.invalidate(recipeDraftProvider);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                if (widget.onBack != null) {
                  widget.onBack!();
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
                onPressed: () => _saveRecipe(context, ref, draft),
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
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (val) {
                    _triggerFeedback();
                    notifier.update((s) => RecipeDraft(name: val, mainImagePath: s.mainImagePath, components: s.components));
                  },
                  controller: TextEditingController(text: draft.name)..selection = TextSelection.collapsed(offset: draft.name.length),
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
                        final newComps = List<RecipeComponentDraft>.from(s.components)
                          ..add(RecipeComponentDraft(id: DateTime.now().toString()));
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

  Future<void> _saveRecipe(BuildContext context, WidgetRef ref, RecipeDraft draft) async {
    if (draft.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please name your masterpiece first!", style: ArtisanalTheme.hand(color: Colors.white)),
          backgroundColor: ArtisanalTheme.redInk,
        ),
      );
      return;
    }

    _triggerFeedback();
    HapticFeedback.heavyImpact();

    // Map Draft to model
    final newRecipe = model.Recipe(
      id: widget.editingRecipeId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: draft.name,
      mainImageUrl: draft.mainImagePath,
      createdAt: DateTime.now(),
      components: draft.components.map((c) => model.RecipeComponent(
        title: c.title,
        imageUrl: c.imagePath == 'placeholder' ? null : c.imagePath,
        ingredients: c.ingredients.map((i) => model.Ingredient(
          name: i.name,
          amount: i.weight.toString(),
          unit: 'g',
          isFlour: i.isFlour,
        )).toList(),
        steps: c.steps.map((s) => model.RecipeStep(
          description: s.content,
        )).toList(),
      )).toList(),
    );

    if (widget.editingRecipeId != null) {
      await ref.read(recipeListProvider.notifier).updateRecipe(newRecipe);
    } else {
      await ref.read(recipeListProvider.notifier).addRecipe(newRecipe);
    }

    if (context.mounted) {
      // SnackBar removed as per user request
      
      if (widget.onBack != null) {
        widget.onBack!();
      } else {
        Navigator.pop(context);
      }
    }
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
                        child: (path == null || path == 'placeholder')
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
                            : ArtisanalImage(
                                imagePath: path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
                      // Action Overlay when empty (or placeholder)
                      if (path == null || path == 'placeholder')
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
                      if (path != null && path != 'placeholder')
                         Positioned(
                           top: 4,
                           right: 4,
                           child: _mediaActionBtn(
                             Icons.close,
                             () async {
                               final confirmed = await _confirmDeleteMedia(context);
                               if (confirmed == true) {
                                 onSelected(null);
                               }
                             },
                             isSmall: true,
                           ),
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

  Future<bool?> _confirmDeleteMedia(BuildContext context) {
    _triggerFeedback();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("REMOVE MEDIA?", style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to remove this image from the recipe?", style: ArtisanalTheme.hand(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("KEEP IT", style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("REMOVE", style: ArtisanalTheme.hand(color: ArtisanalTheme.redInk, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _showNewIngredientDialog(BuildContext context, WidgetRef ref, String name) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.newIngredientTitle, style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold)),
        content: Text(l10n.newIngredientDesc, style: ArtisanalTheme.hand(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.skipForNow, style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary, fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.addToPantry, style: ArtisanalTheme.hand(color: ArtisanalTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newItem = PantryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        purchasePrice: 0,
        purchaseQuantity: 1000, // Default base
        currentStock: 0,
        unit: 'g',
        lastUpdated: DateTime.now(),
      );
      await ref.read(pantryProvider.notifier).addItem(newItem);
    }
  }

  Widget _mediaActionBtn(IconData icon, VoidCallback onTap, {bool isSmall = false}) {
    return GestureDetector(
      onTap: () {
        _triggerFeedback();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12), // Larger hit area
        child: Container(
          padding: EdgeInsets.all(isSmall ? 4 : 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: isSmall ? 14 : 20),
        ),
      ),
    );
  }

  Widget _buildComponentSection(
      BuildContext context, WidgetRef ref, RecipeComponentDraft component, int index) {
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
                    enableSuggestions: false,
                    autocorrect: false,
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
                  icon: Icon(
                    Icons.add_photo_alternate_outlined, 
                    size: 20, 
                    color: component.imagePath == null 
                        ? ArtisanalTheme.outline 
                        : (component.imagePath == 'placeholder' 
                            ? ArtisanalTheme.primary 
                            : ArtisanalTheme.outline.withValues(alpha: 0.3)), // Faded when locked
                  ),
                  onPressed: (component.imagePath != null && component.imagePath != 'placeholder')
                      ? null // LOCKED when actual image exists
                      : () {
                          _triggerFeedback();
                          notifier.update((s) {
                            component.imagePath = component.imagePath == null ? 'placeholder' : null;
                            return RecipeDraft(
                                name: s.name,
                                mainImagePath: s.mainImagePath,
                                components: s.components);
                          });
                        },
                ),
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: ArtisanalTheme.redInk),
                    onPressed: () {
                      _triggerFeedback();
                      notifier.update((s) {
                        final newComps = List<RecipeComponentDraft>.from(s.components)..removeAt(index);
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
                  component.steps.add(RecipeStepDraft(id: DateTime.now().toString()));
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

  Widget _buildIngredientRow(WidgetRef ref, RecipeComponentDraft component, IngredientEntry entry, int index) {
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
                RawAutocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    final pantryItems = ref.read(pantryProvider);
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return pantryItems
                        .where((item) => item.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                        .map((item) => item.name);
                  },
                  onSelected: (String selection) {
                    _triggerFeedback();
                    entry.name = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    if (controller.text != entry.name && entry.name.isNotEmpty) {
                      controller.text = entry.name;
                    }
                    return TextField(
                      focusNode: focusNode,
                      controller: controller,
                      enableSuggestions: false,
                      autocorrect: false,
                      onChanged: (val) {
                        _triggerFeedback();
                        entry.name = val;
                      },
                      onSubmitted: (val) {
                        onFieldSubmitted();
                        // Check if it's a new ingredient
                        final pantryItems = ref.read(pantryProvider);
                        final exists = pantryItems.any((item) => item.name.toLowerCase() == val.trim().toLowerCase());
                        if (!exists && val.trim().isNotEmpty) {
                          _showNewIngredientDialog(context, ref, val.trim());
                        }
                      },
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
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        color: const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 200,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(option, style: ArtisanalTheme.hand(fontSize: 16)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
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
                  enableSuggestions: false,
                  autocorrect: false,
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
                  controller: TextEditingController(
                      text: entry.weight == 0 ? '' : entry.weight.toStringAsFixed(0))
                    ..selection = TextSelection.collapsed(
                        offset: (entry.weight == 0
                                ? ''
                                : entry.weight.toStringAsFixed(0))
                            .length),
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

  Widget _buildStepRow(WidgetRef ref, RecipeComponentDraft component, RecipeStepDraft step, int index) {
    final notifier = ref.read(recipeDraftProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text("${index + 1}.", style: ArtisanalTheme.hand(fontSize: 16, color: ArtisanalTheme.secondary)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (val) {
                 _triggerFeedback();
                 step.content = val;
              },
              controller: TextEditingController(text: step.content)
                ..selection =
                    TextSelection.collapsed(offset: step.content.length),
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
