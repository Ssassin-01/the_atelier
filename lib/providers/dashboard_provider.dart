import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardState {
  final bool isQuoteMode;
  final String resolution;

  DashboardState({
    required this.isQuoteMode,
    required this.resolution,
  });

  DashboardState copyWith({
    bool? isQuoteMode,
    String? resolution,
  }) {
    return DashboardState(
      isQuoteMode: isQuoteMode ?? this.isQuoteMode,
      resolution: resolution ?? this.resolution,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState(isQuoteMode: true, resolution: "")) {
    _init();
  }

  Box get _box => Hive.box('settings');

  void _init() {
    final isQuoteMode = _box.get('isQuoteMode', defaultValue: true);
    final resolution = _box.get('resolution', defaultValue: "");
    state = DashboardState(isQuoteMode: isQuoteMode, resolution: resolution);
  }

  Future<void> toggleMode() async {
    final newMode = !state.isQuoteMode;
    state = state.copyWith(isQuoteMode: newMode);
    await _box.put('isQuoteMode', newMode);
  }

  Future<void> updateResolution(String text) async {
    state = state.copyWith(resolution: text);
    await _box.put('resolution', text);
  }
}
