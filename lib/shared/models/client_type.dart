enum ClientType {
  particulier,
  commercant;

  /// Extra remise appliquee aux tarifs gros (comptes commerçants).
  static const wholesaleDiscountPercent = 12;

  static ClientType fromApi(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return switch (normalized) {
      'commercant' ||
      'commerçant' ||
      'merchant' ||
      'business' => ClientType.commercant,
      _ => ClientType.particulier,
    };
  }

  String get apiValue => name;

  String get label => switch (this) {
    ClientType.particulier => 'Particulier',
    ClientType.commercant => 'Commerçant',
  };

  String get shortDescription => switch (this) {
    ClientType.particulier => 'Compte personnel',
    ClientType.commercant => 'Compte commerçant',
  };

  bool get isCommercant => this == ClientType.commercant;
}
