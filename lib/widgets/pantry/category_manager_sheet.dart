import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_atelier/widgets/masking_tape.dart';
import '../../theme/artisanal_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/pantry_categories_provider.dart';
import '../../providers/pantry_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class CategoryManagerSheet extends ConsumerStatefulWidget {
  const CategoryManagerSheet({super.key});

  @override
  ConsumerState<CategoryManagerSheet> createState() =>
      _CategoryManagerSheetState();
}

class _CategoryManagerSheetState extends ConsumerState<CategoryManagerSheet> {
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  int _selectedAddColor = 0xFFFFF9C4; // Default to first pastel yellow

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _showRenameDialog(BuildContext context, String oldName) {
    final l10n = AppLocalizations.of(context);
    _editController.text = oldName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.renameCategoryTitle,
          style: ArtisanalTheme.hand(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editController,
              decoration: InputDecoration(
                hintText: l10n.newName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: ArtisanalTheme.hand(color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final newName = _editController.text.trim();
                    if (newName.isNotEmpty && newName != oldName) {
                      ref
                          .read(pantryCategoriesProvider.notifier)
                          .renameCategory(oldName, newName);
                      HapticFeedback.mediumImpact();
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFCFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.manageCategories.toUpperCase(),
          style: ArtisanalTheme.hand(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.deleteCategoryConfirm, style: ArtisanalTheme.hand()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel.toUpperCase(),
              style: ArtisanalTheme.hand(color: ArtisanalTheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(pantryCategoriesProvider.notifier)
                  .removeCategory(category);
              ref
                  .read(pantryProvider.notifier)
                  .bulkUpdateCategory(category, 'Others');
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            child: Text(
              l10n.delete.toUpperCase(),
              style: ArtisanalTheme.hand(
                color: ArtisanalTheme.redInk,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<int> postItColors = [
    0xFFFFF9C4,
    0xFFFFE0B2,
    0xFFF8BBD0,
    0xFFE1F5FE,
    0xFFC8E6C9,
    0xFFF3E5F5,
    0xFFFFECB3,
    0xFFFFCCBC,
    0xFFFCE4EC,
    0xFFE0F2F1,
    0xFFF1F8E9,
    0xFFE8EAF6,
    0xFFF5F5DC,
    0xFFD1D1D1,
    0xFFCFD8DC,
  ];

  void _showColorPalette(
    BuildContext context,
    String category,
    int currentColor,
  ) {
    final l10n = AppLocalizations.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ColorPalette",
      barrierColor: Colors.transparent,
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.easeOutQuart.transform(anim1.value);
        return Stack(
          children: [
            Transform.translate(
              offset: Offset(0, -100 * (1 - curve) + 120),
              child: Opacity(
                opacity: anim1.value,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 240,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0F0),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.selectLabelColor,
                            style: ArtisanalTheme.hand(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black26,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: postItColors.map((c) {
                              final isSelected = currentColor == c;
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(pantryCategoriesProvider.notifier)
                                      .updateColor(category, c);
                                  HapticFeedback.selectionClick();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Color(c),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.black12,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.black87,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesMap = ref.watch(pantryCategoriesProvider);
    final pantryItems = ref.watch(pantryProvider);
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final categories = categoriesMap.keys.toList();
    final customCategories = categories
        .where((c) => c != 'All' && c != 'Others')
        .toList();

    Widget buildStickerBody(
      String category,
      int index,
      bool isLocked, {
      bool isPreview = false,
    }) {
      final colorValue = categoriesMap[category] ?? 0xFFFFF9C4;
      final count = category == 'All'
          ? pantryItems.length
          : pantryItems.where((item) => item.category == category).length;

      return Stack(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Color(colorValue),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    category.toUpperCase(),
                    style: ArtisanalTheme.hand(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    l10n.itemsCountSuffix(count),
                    style: ArtisanalTheme.hand(
                      fontSize: 10,
                      color: Colors.black38,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  const Divider(color: Colors.black12, height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.labelColor,
                        style: ArtisanalTheme.hand(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.black26,
                        ),
                      ),
                      if (!isPreview)
                        GestureDetector(
                          onTap: () {
                            _showColorPalette(context, category, colorValue);
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                            child: const Icon(
                              Icons.palette_outlined,
                              size: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Masking Tape
          const Positioned(top: -12, left: 20, child: MaskingTape(width: 40)),

          if (isLocked)
            Positioned(
              top: 10,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.push_pin, size: 8, color: Colors.black26),
                    const SizedBox(width: 2),
                    Text(
                      l10n.fixedLabel,
                      style: ArtisanalTheme.hand(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (!isLocked && !isPreview)
            Positioned(
              top: 4,
              right: 12,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showRenameDialog(context, category),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 0), // Absolute zero gap
                  GestureDetector(
                    onTap: () => _confirmDelete(context, category),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    Widget buildSticker(String category, int index, bool isLocked) {
      final angle = (index % 3 - 1) * 0.03;
      return Transform.rotate(
        key: ValueKey(category),
        angle: angle,
        child: buildStickerBody(category, index, isLocked),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFFDFCFB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.studioIndexBook.toUpperCase(),
                    style: ArtisanalTheme.hand(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    l10n.customizeLabelsDescription,
                    style: ArtisanalTheme.hand(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.reorderInstruction,
                    style: ArtisanalTheme.hand(
                      fontSize: 10,
                      color: Colors.black26,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Post-it style Add Field
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _addController,
                                    textAlign: TextAlign.center,
                                    style: ArtisanalTheme.hand(
                                      fontSize: 18,
                                      color: ArtisanalTheme.primary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: l10n.writeNewLabelHint,
                                      hintStyle: ArtisanalTheme.hand(
                                        color: ArtisanalTheme.secondary
                                            .withValues(alpha: 0.2),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: ArtisanalTheme.secondary,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    if (_addController.text.trim().isNotEmpty) {
                                      ref
                                          .read(
                                            pantryCategoriesProvider.notifier,
                                          )
                                          .addCategory(
                                            _addController.text.trim(),
                                            _selectedAddColor,
                                          );
                                      _addController.clear();
                                      HapticFeedback.mediumImpact();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...postItColors.map(
                                    (c) => GestureDetector(
                                      onTap: () {
                                        setState(() => _selectedAddColor = c);
                                        HapticFeedback.selectionClick();
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(c),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _selectedAddColor == c
                                                ? Colors.black
                                                : Colors.black12,
                                            width: _selectedAddColor == c
                                                ? 1.5
                                                : 1,
                                          ),
                                        ),
                                        child: _selectedAddColor == c
                                            ? const Icon(
                                                Icons.check,
                                                size: 12,
                                                color: Colors.black,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(top: -12, child: MaskingTape(width: 60)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableGridView.count(
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(pantryCategoriesProvider.notifier)
                      .reorderCategories(oldIndex + 1, newIndex + 1);
                  HapticFeedback.lightImpact();
                },
                header: [buildSticker('All', 0, true)],
                footer: [
                  if (categories.contains('Others'))
                    buildSticker('Others', categories.length - 1, true),
                ],
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.0,
                children: List.generate(customCategories.length, (index) {
                  return buildSticker(
                    customCategories[index],
                    index + 1,
                    false,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
