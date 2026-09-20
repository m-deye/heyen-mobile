import '../../l10n/app_localizations.dart';

String whatsAppDigits(String value) {
  return value.trim().replaceAll(RegExp(r'\D'), '');
}

Uri whatsAppUri({required String phone, required String message}) {
  final digits = whatsAppDigits(phone);
  return Uri.parse(
    'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
  );
}

String orderWhatsAppMessage({
  required String reference,
  required String neighborhood,
  required String landmark,
  required String phone,
  required String paymentLabel,
  required String totalLabel,
  required bool isQuote,
  required String clientTypeLabel,
  required AppLocalizations l10n,
  List<String> items = const [],
}) {
  final kind = isQuote ? l10n.whatsAppQuoteKind : l10n.whatsAppOrderKind;
  final articles = items.isEmpty
      ? ''
      : ' ${l10n.whatsAppArticles} : ${items.join(', ')}.';
  return '${l10n.whatsAppGreeting}, $kind $reference ${l10n.whatsAppConfirmed}. '
      '${l10n.whatsAppProfile} : $clientTypeLabel. '
      '${l10n.whatsAppNeighborhood} : $neighborhood. '
      '${l10n.whatsAppLandmark} : $landmark. '
      '${l10n.whatsAppPhone} : $phone. '
      '${l10n.whatsAppPayment} : $paymentLabel. '
      '${l10n.whatsAppTotal} : $totalLabel.$articles';
}
