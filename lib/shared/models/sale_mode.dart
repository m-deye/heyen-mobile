import 'client_type.dart';

enum SaleMode {
  unit,
  wholesale,
  both;

  static SaleMode fromApi(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return switch (normalized) {
      'wholesale' || 'gros' || 'en gros' || 'bulk' => SaleMode.wholesale,
      'both' ||
      'mixte' ||
      'unite_et_gros' ||
      'unit_and_wholesale' => SaleMode.both,
      _ => SaleMode.unit,
    };
  }

  String get apiValue => name;

  String get label => switch (this) {
    SaleMode.unit => 'À l\'unité',
    SaleMode.wholesale => 'En gros',
    SaleMode.both => 'Unité et gros',
  };

  bool get soldByUnit => this != SaleMode.wholesale;
  bool get soldWholesale => this != SaleMode.unit;

  String priceSuffixFor(ClientType type) {
    if (this == SaleMode.wholesale ||
        (this == SaleMode.both && type.isCommercant)) {
      return '/ gros';
    }
    return '/ unité';
  }
}
