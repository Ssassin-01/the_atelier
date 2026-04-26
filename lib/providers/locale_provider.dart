import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale?>((ref) {
  // Return null to let Flutter determine the locale from system settings
  return null;
});
