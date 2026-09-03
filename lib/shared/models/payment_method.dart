enum MobilePaymentMethod {
  bankily,
  masrivi,
  sedad,
  cash;

  String get label => switch (this) {
    MobilePaymentMethod.bankily => 'Bankily',
    MobilePaymentMethod.masrivi => 'Masrivi',
    MobilePaymentMethod.sedad => 'Sedad',
    MobilePaymentMethod.cash => 'Espèces',
  };

  String get description => switch (this) {
    MobilePaymentMethod.bankily => 'Paiement mobile Bankily',
    MobilePaymentMethod.masrivi => 'Paiement mobile Masrivi',
    MobilePaymentMethod.sedad => 'Paiement mobile Sedad',
    MobilePaymentMethod.cash => 'Paiement en espèces',
  };

  bool get requiresWallet => this != MobilePaymentMethod.cash;

  String get apiValue => name;

  static MobilePaymentMethod? fromApi(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    for (final method in MobilePaymentMethod.values) {
      if (method.name == normalized ||
          method.label.toLowerCase() == normalized) {
        return method;
      }
    }
    if (normalized.contains('espece') ||
        normalized.contains('cash') ||
        normalized.contains('piece')) {
      return MobilePaymentMethod.cash;
    }
    return null;
  }
}
