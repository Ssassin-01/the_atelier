import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsState {
  final String weightUnit;
  final String currencySymbol;
  final String currencyCode;
  final String atelierName;
  final String atelierContact;
  final Map<String, double> customRates;

  SettingsState({
    required this.weightUnit,
    required this.currencySymbol,
    required this.currencyCode,
    required this.atelierName,
    required this.atelierContact,
    this.customRates = const {},
  });

  NumberFormat get currencyFormat => NumberFormat.currency(
        symbol: currencySymbol,
        decimalDigits: (currencySymbol == '₩' || currencySymbol == '¥' || currencySymbol == '￥' || currencySymbol == String.fromCharCode(8361)) ? 0 : 2,
      );

  // Exchange rates relative to KRW (Base)
  double get exchangeRate {
    // 1. Check if we have a fresh rate from the API
    if (customRates.containsKey(currencyCode)) {
      return customRates[currencyCode]!;
    }

    // 2. Fallback to hardcoded defaults (Updated for 2026-05-01)
    switch (currencyCode) {
      case 'USD': return 0.00068;
      case 'EUR': return 0.00058;
      case 'JPY': return 0.107;
      default: return 1.0;
    }
  }

  // Converts and formats an amount from KRW to the current currency
  String format(double amountInKRW) {
    final converted = amountInKRW * exchangeRate;
    return currencyFormat.format(converted);
  }

  // Returns raw converted value for charts or logic
  double convert(double amountInKRW) {
    return amountInKRW * exchangeRate;
  }

  SettingsState copyWith({
    String? weightUnit,
    String? currencySymbol,
    String? currencyCode,
    String? atelierName,
    String? atelierContact,
    Map<String, double>? customRates,
  }) {
    return SettingsState(
      weightUnit: weightUnit ?? this.weightUnit,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      atelierName: atelierName ?? this.atelierName,
      atelierContact: atelierContact ?? this.atelierContact,
      customRates: customRates ?? this.customRates,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Box _box;

  SettingsNotifier(this._box)
    : super(
        SettingsState(
          weightUnit: _box.get('weightUnit', defaultValue: 'g'),
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
        ),
      ) {
    // Refresh rates on initialization
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
      final response = await http.get(Uri.parse('https://www.frankfurter.app/latest?from=KRW'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> rates = data['rates'];
        final Map<String, double> newRates = {};
        rates.forEach((key, value) {
          newRates[key] = (value as num).toDouble();
        });
        
        _box.put('customRates', newRates);
        _box.put('lastRefreshDate', DateFormat('yyyy-MM-dd').format(DateTime.now()));
        state = state.copyWith(customRates: newRates);
      }
    } catch (e) {
      // Silently fail if network is down, using cached or hardcoded rates
    }
  }

  void updateWeightUnit(String unit) {
    _box.put('weightUnit', unit);
    state = state.copyWith(weightUnit: unit);
  }

  void updateCurrencySymbol(String symbol) {
    _box.put('currencySymbol', symbol);
    // Automatically determine currency code from symbol for this simple demo
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
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final box = Hive.box('settings');
    return SettingsNotifier(box);
  },
);
