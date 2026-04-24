import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final pantryCategoriesProvider = StateNotifierProvider<PantryCategoriesNotifier, List<String>>((ref) {
  return PantryCategoriesNotifier();
});

class PantryCategoriesNotifier extends StateNotifier<List<String>> {
  PantryCategoriesNotifier() : super(['All', 'Flour', 'Dairy/Eggs', 'Sweetener', 'Leavening', 'Add-in', 'Others']) {
    _loadCategories();
  }

  Box<dynamic> get _box => Hive.box('settings');

  void _loadCategories() {
    final saved = _box.get('pantry_categories');
    if (saved != null && saved is List) {
      // Ensure 'All' is always present at index 0 and others follow
      final List<String> loaded = List<String>.from(saved);
      if (!loaded.contains('All')) {
        loaded.insert(0, 'All');
      }
      state = loaded;
    }
  }

  Future<void> addCategory(String category) async {
    if (!state.contains(category)) {
      state = [...state, category];
      await _box.put('pantry_categories', state);
    }
  }

  Future<void> removeCategory(String category) async {
    if (category != 'All' && category != 'Others') {
      state = state.where((c) => c != category).toList();
      await _box.put('pantry_categories', state);
    }
  }

  Future<void> renameCategory(String oldName, String newName) async {
    if (oldName == 'All' || oldName == 'Others') return;
    state = state.map((c) => c == oldName ? newName : c).toList();
    await _box.put('pantry_categories', state);
  }
}
