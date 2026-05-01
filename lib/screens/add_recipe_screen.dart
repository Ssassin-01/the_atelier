import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../providers/pantry_categories_provider.dart';
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
import '../models/pantry_item.dart';
import '../providers/settings_provider.dart';
import '../providers/pantry_provider.dart';

// ── Data Models ─────────────────────────────────────────────────────────────
class IngredientEntry {
  final String id;
  String name;
  double weight;
  String unit;
  bool isFlour;
  String category;

  IngredientEntry({
    required this.id,
    this.name = '',
    this.weight = 0,
    this.unit = 'g',
    this.isFlour = false,
    this.category = 'Others',
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
    String? title,
    this.imagePath,
    List<IngredientEntry>? ingredients,
    List<RecipeStepDraft>? steps,
    String defaultUnit = 'g',
  }) : title = title ?? '',
       ingredients =
           ingredients ??
           [
             IngredientEntry(
               id: 'i_${DateTime.now().millisecondsSinceEpoch}_1',
               unit: defaultUnit,
             ),
           ],
       steps =
           steps ??
           [
             RecipeStepDraft(
               id: 's_${DateTime.now().millisecondsSinceEpoch}_1',
             ),
           ];

  double get totalFlour =>
      ingredients.where((e) => e.isFlour).fold(0.0, (sum, e) => sum + e.weight);

  double get totalWeight => ingredients.fold(0.0, (sum, e) => sum + e.weight);
}

class RecipeDraft {
  String name;
  String description;
  String? mainImagePath;
  List<RecipeComponentDraft> components;

  RecipeDraft({
    this.name = '',
    this.description = '',
    this.mainImagePath,
    List<RecipeComponentDraft>? components,
  }) : components =
           components ??
           [
             RecipeComponentDraft(
               id: 'c_${DateTime.now().millisecondsSinceEpoch}',
             ),
           ];

  double get totalWeight =>
      components.fold(0.0, (sum, c) => sum + c.totalWeight);

  RecipeDraft copyWith({
    String? name,
    String? description,
    String? mainImagePath,
    List<RecipeComponentDraft>? components,
  }) {
    return RecipeDraft(
      name: name ?? this.name,
      description: description ?? this.description,
      mainImagePath: mainImagePath ?? this.mainImagePath,
      components: components ?? this.components,
    );
  }

  static RecipeDraft fromModel(model.Recipe recipe, SettingsState settings) {
    return RecipeDraft(
      name: recipe.name,
      description: recipe.description ?? '',
      mainImagePath: recipe.mainImageUrl,
      components: recipe.components
          .map(
            (c) => RecipeComponentDraft(
              id: DateTime.now().millisecondsSinceEpoch.toString() + c.title,
              title: c.title,
              imagePath: c.imageUrl,
              ingredients: c.ingredients
                  .map(
                    (i) => IngredientEntry(
                      id:
                          DateTime.now().millisecondsSinceEpoch.toString() +
                          i.name,
                      name: i.name,
                      weight: settings.convertToGrams(double.tryParse(i.amount) ?? 0, i.unit),
                      unit: i.unit,
                      isFlour: i.isFlour,
                    ),
                  )
                  .toList(),
              steps: c.steps
                  .map(
                    (s) => RecipeStepDraft(
                      id:
                          DateTime.now().millisecondsSinceEpoch.toString() +
                          s.description.substring(
                            0,
                            math.min(5, s.description.length),
                          ),
                      content: s.description,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}

final recipeDraftProvider = StateProvider.autoDispose<RecipeDraft>(
  (ref) => RecipeDraft(),
);

class AddRecipeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final String? editingRecipeId;
  const AddRecipeScreen({super.key, this.onBack, this.editingRecipeId});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, GlobalKey> _photoKeys = {};
  final ScrollController _scrollController = ScrollController();

  void _triggerFeedback() {
    HapticFeedback.lightImpact();
  }

  TextEditingController _getController(String id, String initialText) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = TextEditingController(text: initialText);
    }
    return _controllers[id]!;
  }

  FocusNode _getFocusNode(String id) {
    if (!_focusNodes.containsKey(id)) {
      _focusNodes[id] = FocusNode();
    }
    return _focusNodes[id]!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.editingRecipeId != null) {
      Future.microtask(() {
        final recipes = ref.read(recipeListProvider);
        final existing = recipes
            .where((r) => r.id == widget.editingRecipeId)
            .firstOrNull;
        if (existing != null) {
          final settings = ref.read(settingsProvider);
          final draft = RecipeDraft.fromModel(existing, settings);
          _nameController.text = draft.name;
          _descController.text = draft.description;
          ref.read(recipeDraftProvider.notifier).state = draft;
        }
      });
    } else {
      Future.microtask(() {
        ref.invalidate(recipeDraftProvider);
        _nameController.clear();
        _descController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(recipeDraftProvider);
    final notifier = ref.read(recipeDraftProvider.notifier);
    final settings = ref.watch(settingsProvider);

    // Remove English patching logic to respect user request and l10n

    return Scaffold(
      backgroundColor: const Color(
        0xFFFAF9F6,
      ), // Reverted to original Linen White
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: ArtisanalTheme.ink),
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
              style: ArtisanalTheme.hand(
                fontSize: 16,
                color: ArtisanalTheme.secondary,
                letterSpacing: 2,
              ),
            ),
            actions: [
              IconButton(
                padding: const EdgeInsets.only(right: 8),
                icon: const Icon(
                  Icons.auto_stories_outlined,
                  color: ArtisanalTheme.primary,
                ),
                tooltip: l10n.previewInJournal,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      builder: (_, controller) =>
                          RecipePreviewSheet(draft: draft),
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () => _saveRecipe(context, ref, draft, settings),
                child: Text(
                  'SAVE',
                  style: ArtisanalTheme.hand(
                    fontSize: 18,
                    color: ArtisanalTheme.primary,
                  ),
                ),
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
                      child: _buildPhotoSelector(
                        context,
                        draft.mainImagePath,
                        (path) {
                          notifier.update(
                            (s) => RecipeDraft(
                              name: s.name,
                              description: s.description,
                              mainImagePath: path,
                              components: s.components,
                            ),
                          );
                        },
                        height: 280,
                        label: l10n.addCoverMedia,
                      ),
                    ),
                    const MaskingTape(width: 140, label: "MAIN VIEW"),
                  ],
                ),

                const SizedBox(height: 32),
                TextField(
                  onChanged: (val) {
                    _triggerFeedback();
                    notifier.update(
                      (s) => RecipeDraft(
                        name: val,
                        description: s.description,
                        mainImagePath: s.mainImagePath,
                        components: s.components,
                      ),
                    );
                  },
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: l10n.recipeNameHint,
                    hintStyle: GoogleFonts.notoSerif(
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                      color: ArtisanalTheme.ink.withValues(alpha: 0.1),
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ArtisanalTheme.primary,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1),
                    ),
                  ),
                  style: GoogleFonts.notoSerif(
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    color: ArtisanalTheme.ink,
                  ),
                ),

                // ── Description (Artisanal Notes) Section ──────────────────────────
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFBF7), // Creamy paper color
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: ArtisanalTheme.ink.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            size: 18,
                            color: ArtisanalTheme.primary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.artisanalNotes.toUpperCase(),
                            style: ArtisanalTheme.hand(
                              fontSize: 13,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: ArtisanalTheme.secondary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (val) {
                          _triggerFeedback();
                          notifier.update((s) => s.copyWith(description: val));
                        },
                        controller: _descController,
                        maxLines: null,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: l10n.recipeDescriptionHint,
                          hintStyle: ArtisanalTheme.hand(
                            fontSize: 16,
                            color: ArtisanalTheme.ink.withValues(alpha: 0.15),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: ArtisanalTheme.hand(
                          fontSize: 17,
                          height: 1.6,
                          color: ArtisanalTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Summary Row (Subtle) ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      l10n.estWeight,
                      style: ArtisanalTheme.hand(
                        fontSize: 12,
                        color: ArtisanalTheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      settings.formatWeight(draft.totalWeight, settings.weightUnit),
                      style: GoogleFonts.notoSerif(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ArtisanalTheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (draft.components.any(
                  (c) => c.ingredients.isNotEmpty && c.totalFlour == 0,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: ArtisanalTheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ArtisanalTheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 18,
                                color: ArtisanalTheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.bakerPercentageTip,
                                  style: ArtisanalTheme.hand(
                                    fontSize: 14,
                                    color: ArtisanalTheme.ink.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                size: 18,
                                color: ArtisanalTheme.secondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.unitSelectionTip,
                                  style: ArtisanalTheme.hand(
                                    fontSize: 14,
                                    color: ArtisanalTheme.ink.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                ...draft.components.asMap().entries.map(
                  (entry) => _buildComponentSection(
                    context,
                    ref,
                    entry.value,
                    entry.key,
                    l10n,
                    settings,
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _triggerFeedback();
                      final newId = DateTime.now().millisecondsSinceEpoch.toString();
                      notifier.update((s) {
                        final newComps =
                            List<RecipeComponentDraft>.from(s.components)..add(
                              RecipeComponentDraft(
                                id: newId,
                              ),
                            );
                        return s.copyWith(components: newComps);
                      });
                      // Auto-scroll to new component and FOCUS it
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        }
                        // Request focus for the newly added component's title
                        _getFocusNode("${newId}_title").requestFocus();
                      });
                    },
                    icon: const Icon(Icons.library_add_outlined),
                    label: Text(
                      l10n.addAnotherComponent,
                      style: ArtisanalTheme.hand(fontSize: 18),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: ArtisanalTheme.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      side: BorderSide(
                        color: ArtisanalTheme.secondary.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Future<void> _saveRecipe(
    BuildContext context,
    WidgetRef ref,
    RecipeDraft draft,
    SettingsState settings,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (draft.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.nameYourMasterpiece,
            style: ArtisanalTheme.hand(color: Colors.white),
          ),
          backgroundColor: ArtisanalTheme.redInk,
        ),
      );
      return;
    }

    _triggerFeedback();

    // Check for new ingredients that aren't in the pantry yet
    final pantryItems = ref.read(pantryProvider);
    final allIngredientNames = draft.components
        .expand((c) => c.ingredients)
        .where((i) => i.name.trim().isNotEmpty)
        .map((i) => i.name.trim())
        .toSet()
        .toList();

    final newIngredientNames = allIngredientNames
        .where(
          (name) => !pantryItems.any(
            (p) => p.name.toLowerCase() == name.toLowerCase(),
          ),
        )
        .toList();

    if (newIngredientNames.isNotEmpty) {
      final toRegister = await _showBulkNewIngredientsDialog(
        context,
        newIngredientNames,
      );
      
      // If user clicked CANCEL (returns null), abort the whole save process
      if (toRegister == null) return;

      // If user clicked REGISTER (returns non-empty list)
      if (toRegister.isNotEmpty) {
        for (final entry in toRegister) {
          final newItem = PantryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + entry.name,
            name: entry.name,
            purchasePrice: 0,
            targetQuantity: 1000,
            currentStock: 0,
            unit: 'g',
            lastUpdated: DateTime.now(),
            category: entry.category,
          );
          await ref.read(pantryProvider.notifier).addItem(newItem);
        }
      }
      // If toRegister is empty (returns []), it was a SKIP. Proceed to save recipe without registering.
    }

    HapticFeedback.heavyImpact();

    // Map Draft to model
    final newRecipe = model.Recipe(
      id:
          widget.editingRecipeId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: draft.name,
      description: draft.description,
      mainImageUrl: draft.mainImagePath,
      createdAt: DateTime.now(),
      components: draft.components
          .map(
            (c) => model.RecipeComponent(
              title: c.title,
              imageUrl: c.imagePath == 'placeholder' ? null : c.imagePath,
              ingredients: c.ingredients
                  .map(
                    (i) => model.Ingredient(
                      name: i.name,
                      amount: settings.fromGrams(i.weight, i.unit).toString(),
                      unit: i.unit,
                      isFlour: i.isFlour,
                    ),
                  )
                  .toList(),
              steps: c.steps
                  .map((s) => model.RecipeStep(description: s.content))
                  .toList(),
            ),
          )
          .toList(),
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
    BuildContext context,
    String? path,
    Function(String?) onSelected, {
    double height = 200,
    String label = "Add Photo",
    bool fullWidth = true,
  }) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: GestureDetector(
        onTap: () => _pickImage(
          context,
          ImageSource.gallery,
          onSelected,
        ), // Default to gallery on main tap
        child: Container(
          width: fullWidth ? double.infinity : 260,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white, // Polaroid white border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 15,
                offset: const Offset(5, 8),
              ),
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
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      color: ArtisanalTheme.outline.withValues(
                                        alpha: 0.3,
                                      ),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      label,
                                      style: ArtisanalTheme.hand(
                                        fontSize: 14,
                                        color: ArtisanalTheme.outline
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
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
                                _mediaActionBtn(
                                  Icons.camera_alt,
                                  () => _pickImage(
                                    context,
                                    ImageSource.camera,
                                    onSelected,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _mediaActionBtn(
                                  Icons.photo_library,
                                  () => _pickImage(
                                    context,
                                    ImageSource.gallery,
                                    onSelected,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _mediaActionBtn(Icons.brush, () async {
                                  final sketchPath =
                                      await Navigator.push<String>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const FullScreenSketchEditor(),
                                        ),
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
                          child: _mediaActionBtn(Icons.close, () async {
                            final confirmed = await _confirmDeleteMedia(
                              context,
                            );
                            if (confirmed == true) {
                              onSelected(null);
                            }
                          }, isSmall: true),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  path != null && path.contains('sketch')
                      ? l10n.handDrawnSketch
                      : l10n.snapOfTheDay,
                  style: ArtisanalTheme.hand(
                    fontSize: 12,
                    color: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteMedia(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _triggerFeedback();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.removeMedia,
          style: ArtisanalTheme.hand(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.removeMediaConfirm,
          style: ArtisanalTheme.hand(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.keepIt,
              style: ArtisanalTheme.hand(
                color: ArtisanalTheme.secondary,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.remove,
              style: ArtisanalTheme.hand(
                color: ArtisanalTheme.redInk,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<({String name, String category})>?> _showBulkNewIngredientsDialog(
    BuildContext context,
    List<String> names,
  ) async {
    final l10n = AppLocalizations.of(context);
    final Map<String, String> selectedCategories = {
      for (var name in names) name: 'Others',
    };
    final categories = ref
        .read(pantryCategoriesProvider)
        .keys
        .where((c) => c != 'All')
        .toList();

    return showDialog<List<({String name, String category})>?>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal by clicking outside
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFDFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.newIngredientsFound,
            style: ArtisanalTheme.hand(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addIngredientsToPantry,
                  style: ArtisanalTheme.hand(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      final name = names[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: ArtisanalTheme.hand(
                                fontSize: 18,
                                color: ArtisanalTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: categories.map((c) {
                                final isSelected =
                                    selectedCategories[name] == c;
                                return ChoiceChip(
                                  label: Text(
                                    (c == 'Flour'
                                        ? l10n.categoryFlour
                                        : c == 'Dairy/Eggs'
                                        ? l10n.categoryDairy
                                        : c == 'Sweetener'
                                        ? l10n.categorySweetener
                                        : c == 'Leavening'
                                        ? l10n.categoryLeavening
                                        : c == 'Add-in'
                                        ? l10n.categoryAddIn
                                        : c == 'Others'
                                        ? l10n.categoryOthers
                                        : c),
                                    style: ArtisanalTheme.hand(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white
                                          : ArtisanalTheme.ink,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setDialogState(
                                      () => selectedCategories[name] = c,
                                    );
                                  },
                                  selectedColor: ArtisanalTheme.primary,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(
                                      color: isSelected
                                          ? ArtisanalTheme.primary
                                          : const Color(0xFFE5E0D8),
                                    ),
                                  ),
                                  showCheckmark: false,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                );
                              }).toList(),
                            ),
                            if (index < names.length - 1)
                              const Divider(height: 24, color: Colors.black12),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, []), // Return empty list for SKIP
              child: Text(
                "SKIP",
                style: ArtisanalTheme.hand(
                  color: ArtisanalTheme.secondary,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                selectedCategories.entries
                    .map((e) => (name: e.key, category: e.value))
                    .toList(),
              ),
              child: Text(
                l10n.registerIntoPantry,
                style: ArtisanalTheme.hand(
                  color: ArtisanalTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Explicit Cancel to abort saving
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                l10n.cancel,
                style: ArtisanalTheme.hand(
                  color: ArtisanalTheme.redInk,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaActionBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isSmall = false,
  }) {
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
    BuildContext context,
    WidgetRef ref,
    RecipeComponentDraft component,
    int index,
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    final notifier = ref.read(recipeDraftProvider.notifier);
    final photoKey = _photoKeys.putIfAbsent(component.id, () => GlobalKey());

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ArtisanalTheme.background, // Reverted to original theme color
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ArtisanalTheme.outline.withValues(alpha: 0.12),
        ),
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
                    controller: _getController(
                      "${component.id}_title",
                      component.title,
                    ),
                    focusNode: _getFocusNode("${component.id}_title"),
                    style: ArtisanalTheme.hand(
                      fontSize: 20,
                      color: ArtisanalTheme.primary,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.newComponent, // "새 컴포넌트" or "구성 요소 이름..."
                      hintStyle: ArtisanalTheme.hand(
                        fontSize: 20,
                        color: ArtisanalTheme.outline.withValues(alpha: 0.3),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: ArtisanalTheme.primary,
                          width: 1,
                        ),
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
                              : ArtisanalTheme.outline.withValues(
                                  alpha: 0.3,
                                )), // Faded when locked
                  ),
                  onPressed:
                      (component.imagePath != null &&
                          component.imagePath != 'placeholder')
                      ? null // LOCKED when actual image exists
                      : () {
                          _triggerFeedback();
                          notifier.update((s) {
                            component.imagePath = component.imagePath == null
                                ? 'placeholder'
                                : null;
                            return RecipeDraft(
                              name: s.name,
                              mainImagePath: s.mainImagePath,
                              components: s.components,
                            );
                          });
                          // Give a small delay for the widget to appear then scroll
                          Future.delayed(const Duration(milliseconds: 150), () {
                            final currentContext = photoKey.currentContext;
                            if (currentContext != null &&
                                currentContext.mounted) {
                              Scrollable.ensureVisible(
                                currentContext,
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                                alignment: 0.5, // Center in screen
                              );
                            }
                          });
                        },
                ),
                if (index > 0)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: ArtisanalTheme.redInk,
                    ),
                    onPressed: () {
                      _triggerFeedback();
                      notifier.update((s) {
                        final newComps = List<RecipeComponentDraft>.from(
                          s.components,
                        )..removeAt(index);
                        return RecipeDraft(
                          name: s.name,
                          mainImagePath: s.mainImagePath,
                          components: newComps,
                        );
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 20),
            Column(
              children: [
                ...component.ingredients.asMap().entries.map(
                  (entry) => _buildIngredientRow(
                    ref,
                    component,
                    entry.value,
                    entry.key,
                    l10n,
                    settings,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      _triggerFeedback();
                      notifier.update((s) {
                        component.ingredients.add(
                          IngredientEntry(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            unit: settings.measurementSystem == 'metric' ? 'g' : 'oz',
                          ),
                        );
                        return s.copyWith(components: s.components);
                      });
                    },
                    icon: const Icon(Icons.add, size: 14),
                    label: Text(
                      l10n.addIngredient,
                      style: ArtisanalTheme.hand(fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: ArtisanalTheme.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      side: BorderSide(
                        color: ArtisanalTheme.secondary.withValues(alpha: 0.1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              l10n.tabMethods.toUpperCase(),
              style: ArtisanalTheme.receipt(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: ArtisanalTheme.secondary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ...component.steps.asMap().entries.map(
              (stepEntry) => _buildStepRow(
                ref,
                component,
                stepEntry.value,
                stepEntry.key,
                l10n,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _triggerFeedback();
                notifier.update((s) {
                  component.steps.add(
                    RecipeStepDraft(id: DateTime.now().toString()),
                  );
                  return s.copyWith(components: s.components);
                });
              },
              icon: const Icon(Icons.add, size: 14),
              label: Text(
                l10n.addStep,
                style: ArtisanalTheme.hand(fontSize: 14),
              ),
              style: TextButton.styleFrom(
                foregroundColor: ArtisanalTheme.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                side: BorderSide(
                  color: ArtisanalTheme.secondary.withValues(alpha: 0.1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            if (component.imagePath != null) ...[
              const SizedBox(height: 48),
              Center(
                key: photoKey,
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
                            return s.copyWith(components: s.components);
                          });
                        },
                        height: 280,
                        label: l10n.snapOrSketch,
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

  Widget _buildIngredientRow(
    WidgetRef ref,
    RecipeComponentDraft component,
    IngredientEntry entry,
    int index,
    AppLocalizations l10n,
    SettingsState settings,
  ) {
    final notifier = ref.read(recipeDraftProvider.notifier);
    final totalFlour = component.totalFlour;
    final percentage = (totalFlour > 0)
        ? (entry.weight / totalFlour) * 100
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // Icon alignment with toggle functionality
          GestureDetector(
            onTap: () {
              _triggerFeedback();
              notifier.update((s) {
                entry.isFlour = !entry.isFlour;
                return RecipeDraft(
                  name: s.name,
                  mainImagePath: s.mainImagePath,
                  components: s.components,
                );
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
                        .where(
                          (item) => item.name.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                        )
                        .map((item) => item.name);
                  },
                  onSelected: (String selection) {
                    _triggerFeedback();
                    entry.name = selection;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        if (controller.text != entry.name &&
                            entry.name.isNotEmpty) {
                          controller.text = entry.name;
                        }
                        return TextField(
                          focusNode: focusNode,
                          controller: controller,
                          textInputAction: TextInputAction.next,
                          onChanged: (val) {
                            _triggerFeedback();
                            entry.name = val;
                          },
                          onSubmitted: (val) {
                            onFieldSubmitted();
                          },
                          style: ArtisanalTheme.hand(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: l10n.ingredientNameHint, // "예: 유기농 호밀가루"
                            hintStyle: ArtisanalTheme.hand(
                              fontSize: 18,
                              color: ArtisanalTheme.outline.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black12,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ArtisanalTheme.primary,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black12,
                                width: 1.0,
                              ),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
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
                                title: Text(
                                  option,
                                  style: ArtisanalTheme.hand(fontSize: 16),
                                ),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Align height with percentage block on the right (approx 19-23px)
                const SizedBox(height: 23),
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
                      entry.weight = settings.convertToGrams(double.tryParse(val) ?? 0, entry.unit);
                      return RecipeDraft(
                        name: s.name,
                        mainImagePath: s.mainImagePath,
                        components: s.components,
                      );
                    });
                  },
                  controller: _getController(
                    "${entry.id}_weight",
                    entry.weight == 0 ? '' : settings.fromGrams(entry.weight, entry.unit).toStringAsFixed(entry.unit == 'g' ? 0 : 2).replaceAll(RegExp(r'\.?0+$'), ''),
                  ),
                  style: GoogleFonts.notoSerif(
                    fontSize: 16,
                  ), // Match font size for alignment
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: GoogleFonts.notoSerif(
                      fontSize: 16,
                      color: ArtisanalTheme.outline.withValues(alpha: 0.2),
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ArtisanalTheme.primary,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1.0),
                    ),
                    suffix: GestureDetector(
                      onTap: () {
                        _triggerFeedback();
                        final options = settings.measurementSystem == 'metric'
                            ? ['g', 'kg']
                            : ['oz', 'lb'];
                        
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            decoration: const BoxDecoration(
                              color: ArtisanalTheme.surface,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.selectUnit.toUpperCase(),
                                  style: ArtisanalTheme.hand(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ...options.map((opt) => ListTile(
                                  onTap: () {
                                    _triggerFeedback();
                                    notifier.update((s) {
                                      final oldVal = settings.fromGrams(entry.weight, entry.unit);
                                      entry.unit = opt;
                                      // Preserve the numerical value when toggling units
                                      entry.weight = settings.convertToGrams(oldVal, opt);
                                      return s.copyWith(components: s.components);
                                    });
                                    Navigator.pop(context);
                                  },
                                  title: Text(
                                    opt.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: ArtisanalTheme.hand(
                                      fontSize: 16,
                                      fontWeight: entry.unit == opt 
                                          ? FontWeight.w900 
                                          : FontWeight.normal,
                                      color: entry.unit == opt
                                          ? ArtisanalTheme.primary
                                          : ArtisanalTheme.ink,
                                    ),
                                  ),
                                )),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ArtisanalTheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.unit,
                          style: ArtisanalTheme.hand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ArtisanalTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                if (entry.weight > 0 && totalFlour > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                          fontWeight: entry.isFlour
                              ? FontWeight.bold
                              : FontWeight.normal,
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
          // Delete button
          GestureDetector(
            onTap: () {
              _triggerFeedback();
              notifier.update((s) {
                component.ingredients.removeAt(index);
                return s.copyWith(components: s.components);
              });
            },
            child: const Icon(
              Icons.close,
              size: 16,
              color: ArtisanalTheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    WidgetRef ref,
    RecipeComponentDraft component,
    RecipeStepDraft step,
    int index,
    AppLocalizations l10n,
  ) {
    final notifier = ref.read(recipeDraftProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            "${index + 1}.",
            style: ArtisanalTheme.hand(
              fontSize: 16,
              color: ArtisanalTheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (val) {
                _triggerFeedback();
                step.content = val;
              },
              controller: _getController(step.id, step.content),
              maxLines: null,
              style: ArtisanalTheme.hand(
                fontSize: 17,
                color: ArtisanalTheme.ink,
              ),
              decoration: InputDecoration(
                hintText: l10n.stepContentHint,
                hintStyle: ArtisanalTheme.hand(
                  fontSize: 17,
                  color: ArtisanalTheme.outline.withValues(alpha: 0.3),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 0.5),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: ArtisanalTheme.primary,
                    width: 1,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12, width: 0.5),
                ),
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove,
              size: 14,
              color: ArtisanalTheme.outline,
            ),
            onPressed: () {
              _triggerFeedback();
              notifier.update((s) {
                component.steps.removeAt(index);
                return s.copyWith(components: s.components);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    ImageSource source,
    Function(String?) onSelected,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        onSelected(pickedFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
      }
    }
  }
}
