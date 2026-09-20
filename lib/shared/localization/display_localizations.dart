import '../../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/client_type.dart';
import '../models/order_status.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/quote.dart';
import '../models/sale_mode.dart';

extension ClientTypeLocalizations on ClientType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ClientType.particulier => l10n.clientTypeIndividual,
    ClientType.commercant => l10n.clientTypeMerchant,
  };

  String localizedShortDescription(AppLocalizations l10n) => switch (this) {
    ClientType.particulier => l10n.clientTypeIndividualDescription,
    ClientType.commercant => l10n.clientTypeMerchantDescription,
  };
}

extension MobilePaymentMethodLocalizations on MobilePaymentMethod {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    MobilePaymentMethod.bankily => l10n.paymentBankily,
    MobilePaymentMethod.masrivi => l10n.paymentMasrivi,
    MobilePaymentMethod.sedad => l10n.paymentSedad,
    MobilePaymentMethod.cash => l10n.paymentCash,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    MobilePaymentMethod.bankily => l10n.paymentBankilyDescription,
    MobilePaymentMethod.masrivi => l10n.paymentMasriviDescription,
    MobilePaymentMethod.sedad => l10n.paymentSedadDescription,
    MobilePaymentMethod.cash => l10n.paymentCashDescription,
  };
}

extension OrderStatusLocalizations on OrderStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    OrderStatus.confirmee => l10n.orderStatusConfirmed,
    OrderStatus.enPreparation => l10n.orderStatusPreparing,
    OrderStatus.enLivraison => l10n.orderStatusDelivering,
    OrderStatus.livree => l10n.orderStatusDelivered,
  };
}

extension QuoteStatusLocalizations on QuoteStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    QuoteStatus.pending => l10n.quoteStatusPending,
    QuoteStatus.approved => l10n.quoteStatusApproved,
    QuoteStatus.rejected => l10n.quoteStatusRejected,
  };
}

extension SaleModeLocalizations on SaleMode {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    SaleMode.unit => l10n.saleModeUnit,
    SaleMode.wholesale => l10n.saleModeWholesale,
    SaleMode.both => l10n.saleModeBoth,
  };

  String localizedPriceSuffixFor(ClientType type, AppLocalizations l10n) {
    if (this == SaleMode.wholesale ||
        (this == SaleMode.both && type.isCommercant)) {
      return l10n.saleModeWholesaleSuffix;
    }
    return l10n.saleModeUnitSuffix;
  }
}

String localizedCategoryLabel(Category category, AppLocalizations l10n) {
  return switch (category.id) {
    'riz' => l10n.categoryRice,
    'huile' => l10n.categoryOil,
    'dattes' => l10n.categoryDates,
    'eau' => l10n.categoryWater,
    'jus' => l10n.categoryJuice,
    'savon' => l10n.categorySoap,
    'lessive' => l10n.categoryLaundry,
    'livraison' => l10n.categoryDelivery,
    _ => category.label,
  };
}

String localizedCategoryDescription(Category category, AppLocalizations l10n) {
  return switch (category.id) {
    'riz' => l10n.categoryRiceDescription,
    'huile' => l10n.categoryOilDescription,
    'dattes' => l10n.categoryDatesDescription,
    'eau' => l10n.categoryWaterDescription,
    'jus' => l10n.categoryJuiceDescription,
    'savon' => l10n.categorySoapDescription,
    'lessive' => l10n.categoryLaundryDescription,
    'livraison' => l10n.categoryDeliveryDescription,
    _ => category.description,
  };
}

List<String> localizedProductBadges(Product product, AppLocalizations l10n) {
  final labels = <String>[
    if (product.stock <= 0)
      l10n.productStockOutShort
    else if (product.stock <= 10)
      l10n.productStockLimited
    else
      l10n.productAvailable,
    if (product.hasDiscount) l10n.productPromo,
    if (product.saleMode.soldWholesale) l10n.productWholesalePrice,
  ];

  final normalizedStatus = product.status.toLowerCase();
  if (normalizedStatus.contains('nouveau') &&
      !labels.any(
        (label) => label.toLowerCase() == l10n.productNew.toLowerCase(),
      )) {
    labels.add(l10n.productNew);
  }
  for (final badge in product.badges) {
    if (badge.trim().isNotEmpty &&
        !labels.any((label) => label.toLowerCase() == badge.toLowerCase())) {
      labels.add(badge);
    }
  }
  return labels;
}

String localizedAuthError(String error, AppLocalizations l10n) {
  return switch (error) {
    'Identifiants incorrects.' => l10n.authInvalidCredentials,
    'Indiquez votre nom complet.' => l10n.authEnterFullNameError,
    'Indiquez un numéro mauritanien à 8 chiffres.' =>
      l10n.authEnterMauritanianPhoneError,
    'Les mots de passe ne correspondent pas.' =>
      l10n.authPasswordsMismatchError,
    'Indiquez le nom de votre boutique.' => l10n.authEnterShopNameError,
    'Le mot de passe doit contenir au moins 8 caractères.' =>
      l10n.authPasswordMinEightError,
    'Indiquez votre nom et prénom.' => l10n.authEnterFirstLastNameError,
    'Impossible de créer le compte.' => l10n.authCreateAccountError,
    'Le mot de passe doit contenir au moins 6 caractères.' =>
      l10n.authPasswordMinSixError,
    'Ce numéro est déjà utilisé.' => l10n.authPhoneAlreadyUsedError,
    'Indiquez une adresse email valide.' => l10n.authInvalidEmailError,
    "Le serveur Heyen n'est pas disponible." => l10n.authServerUnavailableError,
    "Impossible d'envoyer le lien." => l10n.authSendLinkError,
    'Collez le code reçu par email (ou dans la console du serveur).' =>
      l10n.authPasteEmailCodeError,
    'Impossible de réinitialiser le mot de passe.' =>
      l10n.authResetPasswordError,
    _ => error,
  };
}
