// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Heyn';

  @override
  String get languageScreenTitle => 'Choisissez votre langue';

  @override
  String get languageScreenSubtitle =>
      'Vous pourrez la modifier plus tard depuis le profil.';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageFrenchNative => 'Français';

  @override
  String get languageArabicNative => 'العربية';

  @override
  String get languageContinue => 'Continuer';

  @override
  String get languageChangeTitle => 'Langue';

  @override
  String get languageCurrent => 'Langue actuelle';

  @override
  String get languageUpdated => 'Langue mise à jour';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonLoad => 'Charger';

  @override
  String get commonSeeAll => 'Tout voir';

  @override
  String get commonAll => 'Tout';

  @override
  String get commonFilter => 'Filtrer';

  @override
  String get commonSendWhatsApp => 'Envoyer WhatsApp';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get commonBackToLogin => 'Retour à la connexion';

  @override
  String get commonSearchProduct => 'Rechercher un produit...';

  @override
  String get homeSearchResults => 'Résultats';

  @override
  String get commonClear => 'Effacer';

  @override
  String commonProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
      zero: '0 produit',
    );
    return '$_temp0';
  }

  @override
  String commonArticleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: '0 article',
    );
    return '$_temp0';
  }

  @override
  String commonNoResultsFor(Object query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get apiBackendNotConfiguredTitle => 'API backend non configurée';

  @override
  String get apiBackendNotConfiguredMessage =>
      'Ajoutez HEYN_API_BASE_URL avec l\'URL du backend Django pour charger les données réelles.';

  @override
  String get apiBackendUnavailableTitle => 'Connexion au backend impossible';

  @override
  String get apiBackendUnavailableMessage =>
      'Vérifiez la connexion ou la disponibilité du backend.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCategories => 'Catégories';

  @override
  String get navCart => 'Panier';

  @override
  String get navOrders => 'Mes commandes';

  @override
  String get navProfile => 'Profil';

  @override
  String get authSkip => 'Passer';

  @override
  String get authWelcome => 'Bienvenue chez Heyn';

  @override
  String get authContinue => 'Continuer';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authWelcomeSubtitle =>
      'Entrez votre numéro de téléphone pour suivre vos commandes';

  @override
  String get authClientType => 'Type de client';

  @override
  String get authPhoneNumber => 'Numéro de téléphone';

  @override
  String get authEnterPhone => 'Entrez votre numéro';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authYourPassword => 'Votre mot de passe';

  @override
  String get authShowPassword => 'Afficher le mot de passe';

  @override
  String get authHidePassword => 'Masquer le mot de passe';

  @override
  String get authForgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get authVerificationCodeLogin =>
      'Se connecter avec un code de vérification';

  @override
  String get authOr => 'ou';

  @override
  String get authCreateNewAccount => 'Créer un nouveau compte';

  @override
  String get authLegalText =>
      'En continuant, vous acceptez les conditions d\'utilisation et la politique de confidentialité.';

  @override
  String get authNewToHeyn => 'Vous découvrez Heyn ?';

  @override
  String get authCreateYourAccount => 'Créer votre compte';

  @override
  String get authRegisterSubtitle =>
      'Rejoignez Heyn pour commander vos produits du quotidien.';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authShopName => 'Nom de la boutique';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authCreateMyAccount => 'Créer mon compte';

  @override
  String get authAlreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get authLogin => 'Se connecter';

  @override
  String get authForgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get authForgotPasswordSubtitle =>
      'Indiquez l\'email de votre compte. En local, le lien s\'affiche dans le terminal de npm run dev.';

  @override
  String get authResetLinkSent =>
      'Si un compte existe avec cet email, un lien de réinitialisation vient d\'être envoyé.';

  @override
  String get authSendResetLink => 'Envoyer le lien';

  @override
  String get authAlreadyHaveCode => 'J\'ai déjà un code';

  @override
  String get authNewPasswordTitle => 'Nouveau mot de passe';

  @override
  String get authNewPasswordSubtitle =>
      'Collez le code du lien (paramètre token). Le mot de passe doit avoir au moins 8 caractères.';

  @override
  String get authCodeToken => 'Code / token';

  @override
  String get authNewPassword => 'Nouveau mot de passe';

  @override
  String get authConfirm => 'Confirmer';

  @override
  String get authPasswordResetSuccess =>
      'Mot de passe réinitialisé. Connectez-vous.';

  @override
  String get authInvalidCredentials => 'Identifiants incorrects.';

  @override
  String get authEnterFullNameError => 'Indiquez votre nom complet.';

  @override
  String get authEnterMauritanianPhoneError =>
      'Indiquez un numéro mauritanien à 8 chiffres.';

  @override
  String get authPasswordsMismatchError =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get authEnterShopNameError => 'Indiquez le nom de votre boutique.';

  @override
  String get authPasswordMinEightError =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get authEnterFirstLastNameError => 'Indiquez votre nom et prénom.';

  @override
  String get authCreateAccountError => 'Impossible de créer le compte.';

  @override
  String get authPasswordMinSixError =>
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get authPhoneAlreadyUsedError => 'Ce numéro est déjà utilisé.';

  @override
  String get authInvalidEmailError => 'Indiquez une adresse email valide.';

  @override
  String get authServerUnavailableError =>
      'Le serveur Heyen n\'est pas disponible.';

  @override
  String get authSendLinkError => 'Impossible d\'envoyer le lien.';

  @override
  String get authPasteEmailCodeError =>
      'Collez le code reçu par email (ou dans la console du serveur).';

  @override
  String get authResetPasswordError =>
      'Impossible de réinitialiser le mot de passe.';

  @override
  String get guestPhoneTitle => 'Quel est votre numéro ?';

  @override
  String get guestPhoneSubtitle =>
      'On vérifiera si vous avez déjà un compte Heyn';

  @override
  String get guestEditPhone => 'Modifier le numéro';

  @override
  String get guestPasswordTitle => 'Entrez votre mot de passe';

  @override
  String get guestNoAccount => 'Pas encore de compte ? ';

  @override
  String get homeBannerEssentialsTitle => 'Stockez vos essentiels';

  @override
  String get homeBannerWholesaleTitle => 'Gros et détail en un geste';

  @override
  String get homeBannerDeliveryTitle => 'Livraison à Nouakchott';

  @override
  String get homeBannerSubtitle => 'Prix pro sur tout le catalogue';

  @override
  String get homeBannerCta => 'Commander';

  @override
  String get homePopularThisWeek => 'Populaires cette semaine';

  @override
  String get homeCategories => 'Catégories';

  @override
  String get homeNoCategories => 'Aucune catégorie disponible pour le moment';

  @override
  String get homeDeliveryTo => 'Livraison à';

  @override
  String get homeDefaultAddress => 'Tevragh Zeina, Nouakchott';

  @override
  String homeGreeting(Object firstName) {
    return 'Bonsoir, $firstName';
  }

  @override
  String get homeWelcomeBack => 'Bon retour parmi nous';

  @override
  String get homeNoProducts => 'Aucun produit disponible pour le moment';

  @override
  String get homeSeeCategoryProducts =>
      'Voir tous les produits de cette catégorie';

  @override
  String get homeSeeCatalog => 'Voir tout le catalogue';

  @override
  String get homeOtherProducts => 'Autres produits';

  @override
  String get catalogTitle => 'Catalogue Heyn';

  @override
  String get catalogShopByCategory => 'Achetez par catégorie';

  @override
  String get catalogCategorySubtitle =>
      'Choisissez un produit de cette catégorie.';

  @override
  String get catalogMerchantSubtitle =>
      'Prix de gros pour l\'approvisionnement de votre commerce.';

  @override
  String get catalogRetailSubtitle =>
      'Parcourez les catégories et ajoutez vos produits au panier.';

  @override
  String get catalogDelivery => 'Livraison';

  @override
  String get catalogFilterTitle => 'Filtrer le catalogue';

  @override
  String get catalogFilterAllProducts => 'Tous les produits';

  @override
  String get catalogFilterAvailable => 'Disponibles';

  @override
  String get catalogFilterPromotions => 'Promotions';

  @override
  String get catalogFilterPriceAsc => 'Prix croissant';

  @override
  String get catalogFilterPriceDesc => 'Prix décroissant';

  @override
  String get productDetailTitle => 'Détail produit';

  @override
  String get productGenericTitle => 'Produit';

  @override
  String get productUnavailable =>
      'Ce produit n\'est plus dans le catalogue Heyn.';

  @override
  String get productOutOfStock => 'Produit en rupture de stock';

  @override
  String productAddedToCart(Object productName) {
    return '$productName ajouté au panier';
  }

  @override
  String get productCopied => 'Produit copié dans le presse-papiers';

  @override
  String get productDetails => 'Description du produit';

  @override
  String get productQuantity => 'Quantité';

  @override
  String get productSimilarProducts => 'Produits similaires';

  @override
  String get productDetailStockAvailable => 'Disponible';

  @override
  String get productDetailStockLimited => 'Quantité limitée';

  @override
  String get productDetailStockOut => 'Rupture de stock';

  @override
  String get productAddToCart => 'Ajouter au panier';

  @override
  String get productOrder => 'Commander';

  @override
  String get productStockOut => 'Rupture de stock';

  @override
  String get productStockOutShort => 'Rupture';

  @override
  String get productStockLimited => 'Stock limité';

  @override
  String get productAvailable => 'Disponible';

  @override
  String get productPromo => 'Promo';

  @override
  String get productNew => 'Nouveau';

  @override
  String get productWholesalePrice => 'Prix gros';

  @override
  String get cartTitle => 'Panier';

  @override
  String get cartMerchantSubtitle =>
      'Tarifs professionnels, panier type hebdomadaire et devis avant commande.';

  @override
  String get cartRetailSubtitle =>
      'Vos lignes de commande avant validation et votre réapprovisionnement.';

  @override
  String get cartContinueQuote => 'Continuer vers le devis';

  @override
  String get cartPlaceOrder => 'Passer la commande';

  @override
  String get cartEmptyTitle => 'Votre panier est vide';

  @override
  String get cartEmptySubtitle =>
      'Ajoutez des produits depuis le catalogue pour préparer une commande.';

  @override
  String get cartSeeCategories => 'Voir les catégories';

  @override
  String get cartWeeklyTemplateTitle => 'Panier type hebdomadaire';

  @override
  String get cartWeeklyTemplateSubtitle =>
      'Sauvegardez les produits rachetés chaque semaine, puis rechargez-les en un tap.';

  @override
  String get cartNoTemplate => 'Aucun panier type enregistré pour le moment.';

  @override
  String get cartTemplateSaved => 'Panier type enregistré.';

  @override
  String get cartSubtotal => 'Sous-total';

  @override
  String get cartDeliveryFee => 'Frais de livraison';

  @override
  String get cartFinalTotal => 'Total final';

  @override
  String get cartCouponHint => 'Entrez le code promo';

  @override
  String get cartApplyCoupon => 'Appliquer';

  @override
  String get cartFreeDeliveryHint =>
      'Livraison gratuite pour les commandes de plus de MRU 10,000';

  @override
  String get checkoutShopExample => 'Epicerie Al Amal';

  @override
  String get checkoutSubmitQuote => 'Envoyer la demande de devis';

  @override
  String get checkoutConfirmAndPay => 'Confirmer et payer';

  @override
  String get checkoutDeliveryAddress => 'Adresse de livraison';

  @override
  String get checkoutDeliveryTime => 'Créneau de livraison';

  @override
  String get checkoutToday => 'Aujourd\'hui';

  @override
  String get checkoutTomorrow => 'Demain';

  @override
  String get checkoutTimeWindowToday => '9:00 - 12:00';

  @override
  String get checkoutTimeWindowTomorrow => '16:00 - 19:00';

  @override
  String get checkoutPaymentCashOnDelivery => 'Payez le livreur à l\'arrivée';

  @override
  String get checkoutNotesTitle => 'Notes au livreur';

  @override
  String get checkoutNotesHint => 'Exemple : appelez-moi à l\'arrivée';

  @override
  String get checkoutAddressHint => 'Quartier, rue, immeuble…';

  @override
  String get checkoutCompleteLocationError =>
      'Indiquez votre adresse de livraison.';

  @override
  String get checkoutPhoneError => 'Indiquez votre numéro de téléphone.';

  @override
  String get checkoutPaymentMethodError => 'Choisissez un mode de paiement.';

  @override
  String get checkoutWalletPhoneError => 'Indiquez le numéro du compte mobile.';

  @override
  String get checkoutShopNameError => 'Indiquez le nom de la boutique.';

  @override
  String get checkoutQuoteSentTitle => 'Devis envoyé';

  @override
  String get checkoutOrderConfirmedTitle => 'Commande confirmée';

  @override
  String get checkoutOrderSuccessSubtitle =>
      'Nous vous contacterons par téléphone avant l\'arrivée du livreur.';

  @override
  String get checkoutQuoteSuccessSubtitle =>
      'Notre équipe vous contactera pour valider le devis.';

  @override
  String get checkoutOrderNumber => 'Numéro de commande';

  @override
  String get checkoutExpectedDelivery => 'Livraison prévue';

  @override
  String get checkoutFinalAmount => 'Montant final';

  @override
  String get checkoutTrackOrder => 'Suivre la commande';

  @override
  String get checkoutSendInvoiceWhatsApp => 'Envoyer la facture via WhatsApp';

  @override
  String get checkoutReturnHome => 'Retour à l\'accueil';

  @override
  String checkoutQuoteWhatsAppBody(
    Object reference,
    Object phone,
    Object clientType,
  ) {
    return 'Le devis $reference est enregistré et lié au $phone ($clientType). Un message WhatsApp est prêt pour le service client.';
  }

  @override
  String checkoutOrderWhatsAppBody(
    Object reference,
    Object phone,
    Object clientType,
  ) {
    return 'La commande $reference est enregistrée et liée au $phone ($clientType). Un message WhatsApp est prêt pour le service client.';
  }

  @override
  String get checkoutQuoteHeaderTitle => 'Devis gros avant commande';

  @override
  String get checkoutOrderHeaderTitle => 'Confirmer votre commande';

  @override
  String get checkoutQuoteHeaderSubtitle => 'Demande de devis';

  @override
  String get checkoutOrderHeaderSubtitle => 'Checkout';

  @override
  String get deliveryLocationTitle => 'Quartier et repère';

  @override
  String get deliveryLocationSubtitle =>
      'Nouakchott n\'a pas d\'adressage formel fiable. Choisissez un quartier.';

  @override
  String get deliveryLandmark => 'Repère';

  @override
  String get deliveryPhoneNumber => 'Numéro de téléphone';

  @override
  String get paymentMethodTitle => 'Mode Paiement';

  @override
  String get paymentMethodSubtitle =>
      'Sélectionnez votre mode de paiement et confirmez.';

  @override
  String get ordersQuotesTitle => 'Devis';

  @override
  String get ordersHistoryTitle => 'Historique';

  @override
  String get ordersNoOrders => 'Aucune commande pour le moment';

  @override
  String get ordersCurrentTab => 'Commandes en cours';

  @override
  String get ordersPreviousTab => 'Commandes précédentes';

  @override
  String get ordersNoCurrentOrders => 'Aucune commande en cours';

  @override
  String get ordersNoPreviousOrders => 'Aucune commande précédente';

  @override
  String get ordersViewDetails => 'Voir les détails';

  @override
  String get ordersReorder => 'Recommander';

  @override
  String get ordersDetailsTitle => 'Détails de la commande';

  @override
  String get ordersHeaderMerchantTitle => 'Devis et commandes';

  @override
  String get ordersHeaderRetailTitle => 'Historique des commandes';

  @override
  String get ordersHeaderMerchantSubtitle =>
      'Les devis gros attendent la validation admin, puis le paiement mobile.';

  @override
  String get ordersHeaderRetailSubtitle =>
      'Commandes livrées, en cours, et confirmations WhatsApp.';

  @override
  String get ordersNoQuotes => 'Aucun devis pour le moment';

  @override
  String get ordersRejectQuote => 'Refuser';

  @override
  String get ordersApproveQuote => 'Valider';

  @override
  String get ordersPayAndConfirm => 'Payer et confirmer';

  @override
  String ordersPaymentConfirmed(Object paymentMethod) {
    return 'Paiement $paymentMethod confirmé. WhatsApp notifié.';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String notificationsOrderTitle(Object reference) {
    return 'Commande $reference';
  }

  @override
  String get notificationsEmpty => 'Aucune notification pour le moment.';

  @override
  String get notificationsSeeOrders => 'Voir les commandes';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSubtitle => 'Compte et préférences';

  @override
  String get profilePersonalInfo => 'Informations personnelles';

  @override
  String get profileEditInformation => 'Modifier les informations';

  @override
  String get profileShop => 'Boutique';

  @override
  String get profileAddresses => 'Adresses';

  @override
  String get profileRegisteredAddresses => 'Adresses enregistrées';

  @override
  String get profilePaymentMethods => 'Moyens de paiement';

  @override
  String get profileSavedMonthlyCart => 'Panier mensuel enregistré';

  @override
  String get profileHelp => 'Aide';

  @override
  String get profileHelpAndSupport => 'Aide et support';

  @override
  String get profileSupport => 'Support Heyn';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get profileLogoutAction => 'Se déconnecter';

  @override
  String get profileNoAddress => 'Aucune adresse enregistrée pour le moment.';

  @override
  String get profileNoProfile => 'Aucun profil disponible pour le moment';

  @override
  String get profileWhatsAppUnavailable =>
      'Le canal WhatsApp n\'est pas configuré sur cet appareil. Contactez le service client Heyn pour obtenir de l\'aide.';

  @override
  String profileWhatsAppLine(Object phone) {
    return 'WhatsApp : $phone';
  }

  @override
  String get clientTypeIndividual => 'Particulier';

  @override
  String get clientTypeMerchant => 'Commerçant';

  @override
  String get clientTypeIndividualDescription => 'Compte personnel';

  @override
  String get clientTypeMerchantDescription => 'Compte commerçant';

  @override
  String get paymentBankily => 'Bankily';

  @override
  String get paymentMasrivi => 'Masrivi';

  @override
  String get paymentSedad => 'Sedad';

  @override
  String get paymentCash => 'Espèces';

  @override
  String get paymentBankilyDescription => 'Paiement mobile Bankily';

  @override
  String get paymentMasriviDescription => 'Paiement mobile Masrivi';

  @override
  String get paymentSedadDescription => 'Paiement mobile Sedad';

  @override
  String get paymentCashDescription => 'Paiement en espèces';

  @override
  String get saleModeUnit => 'À l\'unité';

  @override
  String get saleModeWholesale => 'En gros';

  @override
  String get saleModeBoth => 'Unité et gros';

  @override
  String get saleModeUnitSuffix => '/ unité';

  @override
  String get saleModeWholesaleSuffix => '/ gros';

  @override
  String get orderStatusConfirmed => 'Confirmée';

  @override
  String get orderStatusPreparing => 'En préparation';

  @override
  String get orderStatusDelivering => 'En livraison';

  @override
  String get orderStatusDelivered => 'Livrée';

  @override
  String get quoteStatusPending => 'En attente admin';

  @override
  String get quoteStatusApproved => 'Devis validé';

  @override
  String get quoteStatusRejected => 'Devis refusé';

  @override
  String get whatsAppSupportMessage => 'Bonjour Heyn, j\'ai besoin d\'aide.';

  @override
  String get whatsAppQuoteKind => 'devis';

  @override
  String get whatsAppOrderKind => 'commande';

  @override
  String get whatsAppArticles => 'Articles';

  @override
  String get whatsAppGreeting => 'Bonjour Heyn';

  @override
  String get whatsAppConfirmed => 'confirmé';

  @override
  String get whatsAppProfile => 'Profil';

  @override
  String get whatsAppNeighborhood => 'Quartier';

  @override
  String get whatsAppLandmark => 'Repère';

  @override
  String get whatsAppPhone => 'Téléphone';

  @override
  String get whatsAppPayment => 'Paiement';

  @override
  String get whatsAppTotal => 'Total';

  @override
  String get categoryRice => 'Riz';

  @override
  String get categoryRiceDescription => 'Toutes les variétés de riz';

  @override
  String get categoryOil => 'Huile';

  @override
  String get categoryOilDescription => 'Huiles de cuisine et formats gros';

  @override
  String get categoryDates => 'Dattes';

  @override
  String get categoryDatesDescription => 'Dattes locales et importées';

  @override
  String get categoryWater => 'Eau';

  @override
  String get categoryWaterDescription => 'Eau minérale et packs';

  @override
  String get categoryJuice => 'Jus';

  @override
  String get categoryJuiceDescription => 'Jus et boissons sucrées';

  @override
  String get categorySoap => 'Savon';

  @override
  String get categorySoapDescription => 'Savons et hygiène quotidienne';

  @override
  String get categoryLaundry => 'Lessive';

  @override
  String get categoryLaundryDescription => 'Lessives poudre et liquide';

  @override
  String get categoryDelivery => 'Livraison';

  @override
  String get categoryDeliveryDescription =>
      'Articles populaires en livraison rapide';
}
