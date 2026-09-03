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
  List<String> items = const [],
}) {
  final kind = isQuote ? 'devis' : 'commande';
  final articles = items.isEmpty ? '' : ' Articles : ${items.join(', ')}.';
  return 'Bonjour Heyn, $kind $reference confirmé. '
      'Profil : $clientTypeLabel. '
      'Quartier : $neighborhood. Repère : $landmark. '
      'Téléphone : $phone. '
      'Paiement : $paymentLabel. Total : $totalLabel.$articles';
}
