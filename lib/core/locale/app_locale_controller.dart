import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const supportedAppLocales = [Locale('fr'), Locale('ar')];

class AppLocaleState {
  const AppLocaleState({
    required this.locale,
    required this.hasSelectedLocale,
    required this.isLoading,
  });

  const AppLocaleState.loading()
    : locale = const Locale('fr'),
      hasSelectedLocale = false,
      isLoading = true;

  final Locale locale;
  final bool hasSelectedLocale;
  final bool isLoading;
}

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, AppLocaleState>(
      AppLocaleController.new,
    );

class AppLocaleController extends Notifier<AppLocaleState> {
  static const _localeCodeKey = 'app.localeCode';

  @override
  AppLocaleState build() {
    _loadPersistedLocale();
    return const AppLocaleState.loading();
  }

  Future<void> setLocale(Locale locale) async {
    final resolvedLocale = _supportedLocaleFor(locale.languageCode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeCodeKey, resolvedLocale.languageCode);
    state = AppLocaleState(
      locale: resolvedLocale,
      hasSelectedLocale: true,
      isLoading: false,
    );
  }

  Future<void> _loadPersistedLocale() async {
    final preferences = await SharedPreferences.getInstance();
    final savedCode = preferences.getString(_localeCodeKey);
    state = AppLocaleState(
      locale: _supportedLocaleFor(savedCode),
      hasSelectedLocale: savedCode != null,
      isLoading: false,
    );
  }

  Locale _supportedLocaleFor(String? languageCode) {
    return supportedAppLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => supportedAppLocales.first,
    );
  }
}
