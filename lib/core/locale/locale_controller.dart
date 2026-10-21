import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const String _prefsKey = 'locale_code';
  static const List<String> supported = ['en', 'fa'];

  final ValueNotifier<Locale> locale =
      ValueNotifier<Locale>(const Locale('en'));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supported.contains(code)) {
      locale.value = Locale(code);
    }
  }

  Future<void> setLocale(String code) async {
    if (!supported.contains(code) || code == locale.value.languageCode) return;
    locale.value = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }
}
