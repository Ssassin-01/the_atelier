import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  final Box _box;

  LocaleNotifier(this._box) : super(null) {
    final savedLanguage = _box.get('language', defaultValue: 'system');
    if (savedLanguage == 'en') {
      state = const Locale('en');
    } else if (savedLanguage == 'ko') {
      state = const Locale('ko');
    } else {
      state = null; // System default
    }
  }

  String get currentLanguageCode {
    return _box.get('language', defaultValue: 'system');
  }

  void setLanguage(String languageCode) {
    _box.put('language', languageCode);
    if (languageCode == 'en') {
      state = const Locale('en');
    } else if (languageCode == 'ko') {
      state = const Locale('ko');
    } else {
      state = null; // System default
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final box = Hive.box('settings');
  return LocaleNotifier(box);
});
