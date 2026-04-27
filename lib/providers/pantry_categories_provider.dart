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
    List<String> loaded = saved != null && saved is List ? List<String>.from(saved) : ['All', 'Flour', 'Dairy/Eggs', 'Sweetener', 'Leavening', 'Add-in', 'Others'];
    
    // Sort logic: All first, mid categories alphabetical, Others last
    loaded.remove('All');
    loaded.remove('Others');
    loaded.sort();
    
    state = ['All', ...loaded, 'Others'];
  }

  Future<void> addCategory(String category) async {
    if (!state.contains(category)) {
      final List<String> newList = [...state];
      newList.add(category);
      // Re-sort
      newList.remove('All');
      newList.remove('Others');
      newList.sort();
      state = ['All', ...newList, 'Others'];
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
    final List<String> newList = state.map((c) => c == oldName ? newName : c).toList();
    // Re-sort
    newList.remove('All');
    newList.remove('Others');
    newList.sort();
    state = ['All', ...newList, 'Others'];
    await _box.put('pantry_categories', state);
  }
}
