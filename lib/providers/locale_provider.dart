import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) {
  // Default to system locale if needed, or stick to English
  return const Locale('en');
});
