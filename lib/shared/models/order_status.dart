enum OrderStatus {
  confirmee,
  enPreparation,
  enLivraison,
  livree;

  String get label => switch (this) {
    OrderStatus.confirmee => 'Confirmée',
    OrderStatus.enPreparation => 'En préparation',
    OrderStatus.enLivraison => 'En livraison',
    OrderStatus.livree => 'Livrée',
  };

  bool get isDelivered => this == OrderStatus.livree;

  OrderStatus get next => switch (this) {
    OrderStatus.confirmee => OrderStatus.enPreparation,
    OrderStatus.enPreparation => OrderStatus.enLivraison,
    OrderStatus.enLivraison => OrderStatus.livree,
    OrderStatus.livree => OrderStatus.livree,
  };

  static OrderStatus fromApi(String? value) {
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    if (normalized.contains('livraison') ||
        normalized.contains('shipping') ||
        normalized.contains('shipped') ||
        normalized.contains('en route')) {
      return OrderStatus.enLivraison;
    }
    if (normalized.contains('livr') || normalized.contains('deliver')) {
      return OrderStatus.livree;
    }
    if (normalized.contains('prepar') || normalized.contains('paye')) {
      return OrderStatus.enPreparation;
    }
    if (normalized.contains('pending') ||
        normalized.contains('attente') ||
        normalized.contains('confirm')) {
      return OrderStatus.confirmee;
    }
    if (normalized.contains('cancel') || normalized.contains('annul')) {
      return OrderStatus.confirmee;
    }
    return OrderStatus.confirmee;
  }
}
