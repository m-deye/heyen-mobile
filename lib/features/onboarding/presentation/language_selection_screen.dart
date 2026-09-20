import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/heyn_theme.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  late Locale _selectedLocale;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedLocale = ref.read(appLocaleControllerProvider).locale;
  }

  Future<void> _saveLanguage() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    await ref
        .read(appLocaleControllerProvider.notifier)
        .setLocale(_selectedLocale);

    if (!mounted) {
      return;
    }

    final redirect = _safeLanguageRedirect(
      GoRouterState.of(context).uri.queryParameters['redirect'],
    );
    context.go(redirect ?? '/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: HeynColors.pageMint,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: HeynCard(
                radius: 28,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      size: 52,
                      color: HeynColors.navy,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.languageScreenTitle,
                      textAlign: TextAlign.center,
                      style: HeynTextStyles.sectionTitle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.languageScreenSubtitle,
                      textAlign: TextAlign.center,
                      style: HeynTextStyles.subtitle,
                    ),
                    const SizedBox(height: 24),
                    RadioGroup<Locale>(
                      groupValue: _selectedLocale,
                      onChanged: (locale) {
                        if (locale != null) {
                          _selectLocale(locale);
                        }
                      },
                      child: Column(
                        children: [
                          _LanguageTile(
                            key: const Key('language-fr'),
                            locale: const Locale('fr'),
                            selectedLocale: _selectedLocale,
                            title: l10n.languageFrenchNative,
                            subtitle: l10n.languageFrench,
                            onChanged: _selectLocale,
                          ),
                          const SizedBox(height: 10),
                          _LanguageTile(
                            key: const Key('language-ar'),
                            locale: const Locale('ar'),
                            selectedLocale: _selectedLocale,
                            title: l10n.languageArabicNative,
                            subtitle: l10n.languageArabic,
                            onChanged: _selectLocale,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('language-continue'),
                      onPressed: _isSaving ? null : _saveLanguage,
                      child: _isSaving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.languageContinue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectLocale(Locale locale) {
    setState(() => _selectedLocale = locale);
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    super.key,
    required this.locale,
    required this.selectedLocale,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final Locale locale;
  final Locale selectedLocale;
  final String title;
  final String subtitle;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = locale.languageCode == selectedLocale.languageCode;

    return HeynCard(
      radius: 18,
      padding: EdgeInsets.zero,
      onTap: () => onChanged(locale),
      child: RadioListTile<Locale>(
        value: locale,
        selected: selected,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

String? _safeLanguageRedirect(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  var decoded = raw.trim();
  try {
    decoded = Uri.decodeComponent(decoded);
  } catch (_) {}

  if (!decoded.startsWith('/') ||
      decoded.startsWith('//') ||
      decoded == '/language' ||
      decoded.startsWith('/language?') ||
      decoded.startsWith('/language/')) {
    return null;
  }
  return decoded;
}
