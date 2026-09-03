import '../../shared/models/category.dart';
import '../../shared/models/client_type.dart';
import '../../shared/models/order.dart';
import '../../shared/models/order_line.dart';
import '../../shared/models/order_status.dart';
import '../../shared/models/product.dart';
import '../../shared/models/recurring_cart.dart';
import '../../shared/models/sale_mode.dart';
import '../../shared/models/user.dart';
import '../../shared/models/user_profile.dart';

class DevSeedData {
  const DevSeedData._();

  static const categories = [
    Category(
      id: 'riz',
      label: 'Riz',
      description: 'Toutes les variétés de riz',
      imageLabel: 'Riz',
    ),
    Category(
      id: 'huile',
      label: 'Huile',
      description: 'Huiles de cuisine et formats gros',
      imageLabel: 'Huile',
    ),
    Category(
      id: 'dattes',
      label: 'Dattes',
      description: 'Dattes locales et importées',
      imageLabel: 'Dat',
    ),
    Category(
      id: 'eau',
      label: 'Eau',
      description: 'Eau minérale et packs',
      imageLabel: 'Eau',
    ),
    Category(
      id: 'jus',
      label: 'Jus',
      description: 'Jus et boissons sucrées',
      imageLabel: 'Jus',
    ),
    Category(
      id: 'savon',
      label: 'Savon',
      description: 'Savons et hygiène quotidienne',
      imageLabel: 'Sav',
    ),
    Category(
      id: 'lessive',
      label: 'Lessive',
      description: 'Lessives poudre et liquide',
      imageLabel: 'Les',
    ),
    Category(
      id: 'livraison',
      label: 'Livraison',
      description: 'Articles populaires en livraison rapide',
      imageLabel: 'Box',
    ),
  ];

  static const products = [
    Product(
      id: 'riz-premium-5kg',
      categoryId: 'riz',
      name: 'Riz premium 5 kg',
      price: 980,
      description: 'Sac de riz parfumé pour la famille.',
      details: 'Riz premium 5 kg. Idéal pour une consommation hebdomadaire.',
      status: 'Disponible',
      discountPercent: 10,
      imageLabel: 'Riz',
      saleMode: SaleMode.unit,
    ),
    Product(
      id: 'huile-tournesol-1l',
      categoryId: 'huile',
      name: 'Huile tournesol 1 L',
      price: 420,
      description: 'Huile de cuisine pour usage quotidien.',
      details: 'Bouteille 1 litre, adaptée à la friture et aux plats maison.',
      status: 'Stock limite',
      imageLabel: 'Huile',
    ),
    Product(
      id: 'dattes-locales-500g',
      categoryId: 'dattes',
      name: 'Dattes locales 500 g',
      price: 350,
      description: 'Dattes locales sucrées, récolte récente.',
      details: 'Sachet 500 g, parfait pour le thé ou le ramadan.',
      status: 'Promo',
      discountPercent: 15,
      imageLabel: 'Dat',
    ),
    Product(
      id: 'eau-minerale-pack',
      categoryId: 'eau',
      name: 'Pack eau minerale',
      price: 760,
      description: 'Pack de 12 bouteilles pour livraison a domicile.',
      details: 'Pack de 12 bouteilles, pratique pour la maison ou le bureau.',
      status: 'Disponible',
      imageLabel: 'Eau',
      saleMode: SaleMode.both,
    ),
    Product(
      id: 'jus-bissap-1l',
      categoryId: 'jus',
      name: 'Jus bissap 1 L',
      price: 260,
      description: 'Jus de bissap frais, prêt à boire.',
      details: 'Bouteille 1 litre à conserver au frais après ouverture.',
      status: 'Nouveau',
      imageLabel: 'Jus',
    ),
    Product(
      id: 'savon-famille',
      categoryId: 'savon',
      name: 'Savon famille',
      price: 180,
      description: 'Savon doux pour toute la famille.',
      details: 'Lot économique pour usage quotidien.',
      status: 'Disponible',
      imageLabel: 'Sav',
      saleMode: SaleMode.both,
    ),
    Product(
      id: 'lessive-2kg',
      categoryId: 'lessive',
      name: 'Lessive 2 kg',
      price: 690,
      description: 'Lessive concentrée pour le linge de maison.',
      details: 'Format 2 kg, mousse abondante et parfum léger.',
      status: 'Promo',
      discountPercent: 8,
      imageLabel: 'Les',
    ),
    Product(
      id: 'kit-commande-rapide',
      categoryId: 'livraison',
      name: 'Kit commande rapide',
      price: 1450,
      description: 'Assortiment prêt à livrer pour gagner du temps.',
      details:
          'Kit composé des produits les plus demandés, livré en une seule commande.',
      status: 'Disponible',
      imageLabel: 'Kit',
      saleMode: SaleMode.wholesale,
    ),
    Product(
      id: 'riz-brise-25kg',
      categoryId: 'riz',
      name: 'Riz brisé 25 kg',
      price: 3850,
      description: 'Sac 25 kg pour commerce et restauration.',
      details: 'Riz brisé économique, format gros pour réapprovisionnement.',
      status: 'Disponible',
      imageLabel: 'Riz',
      saleMode: SaleMode.wholesale,
    ),
    Product(
      id: 'riz-thai-10kg',
      categoryId: 'riz',
      name: 'Riz thaï 10 kg',
      price: 2100,
      description: 'Riz thaï parfumé, grain long.',
      details: 'Sac 10 kg, idéal pour plats du quotidien et riz au gras.',
      status: 'Promo',
      discountPercent: 8,
      imageLabel: 'Riz',
      saleMode: SaleMode.both,
    ),
    Product(
      id: 'riz-local-5kg',
      categoryId: 'riz',
      name: 'Riz local 5 kg',
      price: 720,
      description: 'Riz local mauritanien, récolte récente.',
      details: 'Sac 5 kg, goût authentique pour la table familiale.',
      status: 'Disponible',
      imageLabel: 'Riz',
    ),
    Product(
      id: 'riz-basmati-2kg',
      categoryId: 'riz',
      name: 'Riz basmati 2 kg',
      price: 890,
      description: 'Riz basmati parfumé, grain extra-long.',
      details: 'Format 2 kg, parfait pour plats festifs.',
      status: 'Nouveau',
      imageLabel: 'Riz',
    ),
    Product(
      id: 'huile-palme-5l',
      categoryId: 'huile',
      name: 'Huile de palme 5 L',
      price: 1450,
      description: 'Bidon 5 litres pour friture et cuisine.',
      details: 'Format économique, très demandé en gros.',
      status: 'Disponible',
      imageLabel: 'Huile',
      saleMode: SaleMode.wholesale,
    ),
    Product(
      id: 'huile-arachide-1l',
      categoryId: 'huile',
      name: 'Huile d\'arachide 1 L',
      price: 480,
      description: 'Huile d\'arachide pour sauces et friture légère.',
      details: 'Bouteille 1 litre, goût doux.',
      status: 'Disponible',
      imageLabel: 'Huile',
    ),
    Product(
      id: 'huile-olive-75cl',
      categoryId: 'huile',
      name: 'Huile d\'olive 75 cl',
      price: 920,
      description: 'Huile d\'olive pour assaisonnement.',
      details: 'Bouteille 75 cl, à utiliser à froid ou en fin de cuisson.',
      status: 'Promo',
      discountPercent: 10,
      imageLabel: 'Huile',
    ),
    Product(
      id: 'dattes-deglet-1kg',
      categoryId: 'dattes',
      name: 'Dattes Deglet Nour 1 kg',
      price: 650,
      description: 'Dattes Deglet Nour charnues.',
      details: 'Sachet 1 kg, idéal pour le ramadan et le thé.',
      status: 'Disponible',
      imageLabel: 'Dat',
    ),
    Product(
      id: 'eau-5l',
      categoryId: 'eau',
      name: 'Eau minérale 5 L',
      price: 180,
      description: 'Bonbonne 5 litres pour la maison.',
      details: 'Format familial, pratique au quotidien.',
      status: 'Disponible',
      imageLabel: 'Eau',
    ),
    Product(
      id: 'eau-pack-15l',
      categoryId: 'eau',
      name: 'Pack eau 1,5 L',
      price: 540,
      description: 'Pack de 6 bouteilles 1,5 L.',
      details: 'Idéal bureau, boutique ou livraison.',
      status: 'Disponible',
      imageLabel: 'Eau',
      saleMode: SaleMode.wholesale,
    ),
    Product(
      id: 'jus-mangue-1l',
      categoryId: 'jus',
      name: 'Jus mangue 1 L',
      price: 290,
      description: 'Jus de mangue prêt à boire.',
      details: 'Bouteille 1 litre, à conserver au frais après ouverture.',
      status: 'Disponible',
      imageLabel: 'Jus',
    ),
    Product(
      id: 'jus-orange-1l',
      categoryId: 'jus',
      name: 'Jus orange 1 L',
      price: 310,
      description: 'Jus d\'orange pour le petit-déjeuner.',
      details: 'Bouteille 1 litre, goût fruité.',
      status: 'Promo',
      discountPercent: 5,
      imageLabel: 'Jus',
    ),
    Product(
      id: 'savon-marseille',
      categoryId: 'savon',
      name: 'Savon de Marseille',
      price: 220,
      description: 'Savon traditionnel multi-usages.',
      details: 'Pain de savon pour linge et ménage.',
      status: 'Disponible',
      imageLabel: 'Sav',
    ),
    Product(
      id: 'savon-liquide-500ml',
      categoryId: 'savon',
      name: 'Savon liquide 500 ml',
      price: 260,
      description: 'Savon liquide pour les mains.',
      details: 'Flacon 500 ml, parfum léger.',
      status: 'Nouveau',
      imageLabel: 'Sav',
    ),
    Product(
      id: 'lessive-liquide-3l',
      categoryId: 'lessive',
      name: 'Lessive liquide 3 L',
      price: 780,
      description: 'Lessive liquide concentrée.',
      details: 'Bidon 3 litres pour le linge de maison.',
      status: 'Disponible',
      imageLabel: 'Les',
      saleMode: SaleMode.wholesale,
    ),
  ];

  static int stockFor(String productId) {
    return switch (productId) {
      'dattes-locales-500g' => 0,
      'huile-tournesol-1l' => 4,
      'savon-liquide-500ml' => 8,
      'jus-orange-1l' => 3,
      'eau-5l' => 7,
      'riz-basmati-2kg' => 9,
      _ => 18 + (productId.hashCode.abs() % 30),
    };
  }

  static const particulierUser = User(
    id: 'user-particulier',
    fullName: 'Aminata Diallo',
    type: ClientType.particulier,
    phone: '+222 12345678',
    whatsApp: '+222 12345678',
    address: 'Tevragh Zeina, Nouakchott',
  );

  static const commercantUser = User(
    id: 'user-commercant',
    fullName: 'Mohamed Kane',
    type: ClientType.commercant,
    phone: '+222 87654321',
    whatsApp: '+222 87654321',
    address: 'Marché capital, Nouakchott',
    shopName: 'Epicerie Al Amal',
  );

  static final orders = [
    Order(
      id: 'CMD-1024',
      date: DateTime(2026, 8, 12),
      status: OrderStatus.livree,
      deliveryAddress: 'Tevragh Zeina, Nouakchott',
      lines: [
        OrderLine(product: products[0], quantity: 2),
        OrderLine(product: products[3], quantity: 1),
      ],
    ),
    Order(
      id: 'CMD-1025',
      date: DateTime(2026, 8, 16),
      status: OrderStatus.enPreparation,
      deliveryAddress: 'Ksar, Nouakchott',
      lines: [
        OrderLine(product: products[4], quantity: 3),
        OrderLine(product: products[6], quantity: 1),
      ],
    ),
  ];

  static final merchantOrders = [
    Order(
      id: 'CMD-2040',
      date: DateTime(2026, 8, 10),
      status: OrderStatus.livree,
      deliveryAddress: 'Epicerie Al Amal, Marché capital',
      lines: [
        OrderLine(product: products[0], quantity: 10),
        OrderLine(product: products[3], quantity: 6),
      ],
    ),
    Order(
      id: 'CMD-2041',
      date: DateTime(2026, 8, 17),
      status: OrderStatus.enPreparation,
      deliveryAddress: 'Ksar, Nouakchott',
      lines: [
        OrderLine(product: products[7], quantity: 4),
        OrderLine(product: products[1], quantity: 12),
      ],
    ),
  ];

  static Product withStock(Product product) {
    return product.copyWith(stock: stockFor(product.id));
  }

  static User userFor(ClientType type) {
    return type.isCommercant ? commercantUser : particulierUser;
  }

  static UserProfile profileFor(ClientType type) => userFor(type).toProfile();

  static List<Order> ordersFor(ClientType type) {
    return type.isCommercant ? merchantOrders : orders;
  }

  static final merchantWeeklyCart = RecurringCart(
    name: 'Approvisionnement hebdo',
    updatedAt: DateTime(2026, 8, 11),
    lines: [
      OrderLine(product: withStock(products[0]), quantity: 10),
      OrderLine(product: withStock(products[1]), quantity: 12),
      OrderLine(product: withStock(products[3]), quantity: 6),
    ],
  );

  static const profile = UserProfile(
    fullName: 'Aminata Diallo',
    type: ClientType.particulier,
    phone: '+222 12345678',
    whatsApp: '+222 12345678',
    address: 'Tevragh Zeina, Nouakchott',
  );
}
