import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsState {
  final String measurementSystem; // 'metric' or 'imperial'
  final String currencySymbol;
  final String currencyCode;
  final String atelierName;
  final String atelierContact;
  final Map<String, double> customRates;
  final String appMode; // 'creative', 'business', or 'basic'

  SettingsState({
    required this.measurementSystem,
    required this.currencySymbol,
    required this.currencyCode,
    required this.atelierName,
    required this.atelierContact,
    this.customRates = const {},
    this.appMode = 'business',
  });

  // Backward compatibility getters
  bool get isBusinessMode => appMode == 'business';
  String get weightUnit => measurementSystem == 'metric' ? 'g' : 'oz';

  NumberFormat get currencyFormat => NumberFormat.currency(
        symbol: currencySymbol,
        decimalDigits: (currencySymbol == '₩' || currencySymbol == '¥' || currencySymbol == '￥' || currencySymbol == String.fromCharCode(8361)) ? 0 : 2,
      );

  double get exchangeRate {
    if (customRates.containsKey(currencyCode)) {
      return customRates[currencyCode]!;
    }
    switch (currencyCode) {
      case 'USD': return 0.00068;
      case 'EUR': return 0.00058;
      case 'JPY': return 0.107;
      default: return 1.0;
    }
  }

  String format(double amountInKRW) {
    final converted = amountInKRW * exchangeRate;
    return currencyFormat.format(converted);
  }

  double convert(double amountInKRW) {
    return amountInKRW * exchangeRate;
  }

  double toGrams(double value, String unit) {
    final u = unit.toLowerCase();
    switch (u) {
      case 'g': return value;
      case 'kg': return value * 1000;
      case 'oz': return value * 28.3495;
      case 'lb': return value * 453.592;
      default: return value;
    }
  }

  double fromGrams(double grams, String targetUnit) {
    final u = targetUnit.toLowerCase();
    switch (u) {
      case 'g': return grams;
      case 'kg': return grams / 1000;
      case 'oz': return grams / 28.3495;
      case 'lb': return grams / 453.592;
      default: return grams;
    }
  }

  String formatWeight(double valueInGrams, [String? originalUnit]) {
    if (originalUnit != null && _isWeightUnit(originalUnit)) {
      final scaledValue = fromGrams(valueInGrams, originalUnit);
      if (originalUnit == 'g' || originalUnit == 'oz') {
        return "${scaledValue.toStringAsFixed(0)} $originalUnit";
      }
      return "${_formatDecimal(scaledValue)} $originalUnit";
    }

    if (originalUnit != null && !_isWeightUnit(originalUnit)) {
      return "${_formatDecimal(valueInGrams)} $originalUnit";
    }

    if (measurementSystem == 'metric') {
      if (valueInGrams >= 1000) {
        double kg = valueInGrams / 1000;
        return "${_formatDecimal(kg)} kg";
      }
      return "${valueInGrams.toStringAsFixed(0)} g";
    } else {
      double oz = valueInGrams / 28.3495;
      if (oz >= 16) {
        double lb = oz / 16;
        return "${_formatDecimal(lb)} lb";
      }
      return "${_formatDecimal(oz)} oz";
    }
  }

  String _formatDecimal(double value) {
    if (value == 0) return "0";
    if (value < 1) {
      final text = value.toStringAsFixed(3);
      return text.contains('.') ? text.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : text;
    }
    final text = value.toStringAsFixed(2);
    return text.contains('.') ? text.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : text;
  }

  bool _isWeightUnit(String unit) {
    final u = unit.toLowerCase();
    return u == 'g' || u == 'kg' || u == 'oz' || u == 'lb';
  }

  double convertWeight(double value, String unit) {
    if (!_isWeightUnit(unit)) return value;
    return toGrams(value, unit);
  }

  double convertToGrams(double value, String fromUnit) {
    return toGrams(value, fromUnit);
  }

  double convertToSystemDefault(double grams) {
    if (measurementSystem == 'metric') {
      return grams;
    } else {
      return grams / 28.3495;
    }
  }

  double convertFromSystemUnit(double value, String targetUnit) {
    if (!_isWeightUnit(targetUnit)) return value;
    final grams = measurementSystem == 'metric' ? value : value * 28.3495;
    return fromGrams(grams, targetUnit);
  }

  SettingsState copyWith({
    String? measurementSystem,
    String? currencySymbol,
    String? currencyCode,
    String? atelierName,
    String? atelierContact,
    Map<String, double>? customRates,
    String? appMode,
  }) {
    return SettingsState(
      measurementSystem: measurementSystem ?? this.measurementSystem,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      atelierName: atelierName ?? this.atelierName,
      atelierContact: atelierContact ?? this.atelierContact,
      customRates: customRates ?? this.customRates,
      appMode: appMode ?? this.appMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Box _box;

  SettingsNotifier(this._box)
      : super(
          SettingsState(
            measurementSystem: _box.get('measurementSystem',
                defaultValue: _box.get('weightUnit') == 'oz' ||
                        _box.get('weightUnit') == 'lb'
                    ? 'imperial'
                    : 'metric'),
            currencySymbol: _box.get('currencySymbol', defaultValue: '₩'),
            currencyCode: _box.get('currencyCode', defaultValue: 'KRW'),
            atelierName: _box.get('atelierName', defaultValue: 'Atelier Studio'),
            atelierContact: _box.get(
              'atelierContact',
              defaultValue: 'chef@atelier.com',
            ),
            customRates: Map<String, double>.from(
              _box.get('customRates', defaultValue: <String, double>{}),
            ),
            appMode: _box.get('appMode', defaultValue: _box.get('isBusinessMode', defaultValue: true) ? 'business' : 'creative'),
          ),
        ) {
    checkAndRefreshRates();
  }

  Future<void> checkAndRefreshRates() async {
    final lastRefresh = _box.get('lastRefreshDate') as String?;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastRefresh != today) {
      await refreshRates();
    }
  }

  Future<void> refreshRates() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.frankfurter.app/latest?from=KRW'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> rates = data['rates'];
        final Map<String, double> newRates = {};
        rates.forEach((key, value) {
          newRates[key] = (value as num).toDouble();
        });

        _box.put('customRates', newRates);
        _box.put(
            'lastRefreshDate', DateFormat('yyyy-MM-dd').format(DateTime.now()));
        state = state.copyWith(customRates: newRates);
      }
    } catch (e) {
      // Silently fail if network is down
    }
  }

  void updateMeasurementSystem(String system) {
    _box.put('measurementSystem', system);
    state = state.copyWith(measurementSystem: system);
  }

  void updateCurrencySymbol(String symbol) {
    _box.put('currencySymbol', symbol);
    String code = 'KRW';
    if (symbol == r"$") code = "USD";
    if (symbol == "€") code = "EUR";
    if (symbol == "¥" || symbol == "￥") code = "JPY";
    _box.put('currencyCode', code);
    state = state.copyWith(currencySymbol: symbol, currencyCode: code);
  }

  void updateAtelierProfile({String? name, String? contact}) {
    if (name != null) _box.put('atelierName', name);
    if (contact != null) _box.put('atelierContact', contact);
    state = state.copyWith(
      atelierName: name ?? state.atelierName,
      atelierContact: contact ?? state.atelierContact,
    );
  }

  void updateAppMode(String mode) {
    _box.put('appMode', mode);
    state = state.copyWith(appMode: mode);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final box = Hive.box('settings');
    return SettingsNotifier(box);
  },
);
