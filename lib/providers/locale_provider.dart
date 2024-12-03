import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Locale yönetimi için bir StateNotifier oluşturuyoruz
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(PlatformDispatcher.instance.locale) {
    _loadLocale();
  }

  Future<void> changeLocale(String languageCode) async {
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', languageCode);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selected_locale');
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
