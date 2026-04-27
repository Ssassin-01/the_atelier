import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final categoryIconsProvider = StateNotifierProvider<CategoryIconsNotifier, Map<String, String>>((ref) {
  return CategoryIconsNotifier();
});

class CategoryIconsNotifier extends StateNotifier<Map<String, String>> {
  CategoryIconsNotifier() : super({}) {
    _loadIcons();
  }

  Box<dynamic> get _box => Hive.box('settings');

  void _loadIcons() {
    final Map<dynamic, dynamic>? saved = _box.get('category_icons');
    if (saved != null) {
      state = Map<String, String>.from(saved);
    }
  }

  Future<void> setIcon(String category, String? imagePath) async {
    if (imagePath == null) {
      final newState = {...state};
      newState.remove(category);
      state = newState;
    } else {
      state = {...state, category: imagePath};
    }
    await _box.put('category_icons', state);
  }

  Future<void> migrateIcon(String oldCategory, String newCategory) async {
    final icon = state[oldCategory];
    if (icon != null) {
      final newState = {...state};
      newState.remove(oldCategory);
      newState[newCategory] = icon;
      state = newState;
      await _box.put('category_icons', state);
    }
  }
}
