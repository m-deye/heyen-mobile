import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Heyn'**
  String get appTitle;

  /// No description provided for @languageScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue'**
  String get languageScreenTitle;

  /// No description provided for @languageScreenSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez la modifier plus tard depuis le profil.'**
  String get languageScreenSubtitle;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get languageArabic;

  /// No description provided for @languageFrenchNative.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrenchNative;

  /// No description provided for @languageArabicNative.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabicNative;

  /// No description provided for @languageContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get languageContinue;

  /// No description provided for @languageChangeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageChangeTitle;

  /// No description provided for @languageCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Langue actuelle'**
  String get languageCurrent;

  /// No description provided for @languageUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Langue mise à jour'**
  String get languageUpdated;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonLoad.
  ///
  /// In fr, this message translates to:
  /// **'Charger'**
  String get commonLoad;

  /// No description provided for @commonSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get commonSeeAll;

  /// No description provided for @commonAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get commonAll;

  /// No description provided for @commonFilter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get commonFilter;

  /// No description provided for @commonSendWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer WhatsApp'**
  String get commonSendWhatsApp;

  /// No description provided for @commonTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get commonRemove;

  /// No description provided for @commonBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get commonBackToLogin;

  /// No description provided for @commonSearchProduct.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit...'**
  String get commonSearchProduct;

  /// No description provided for @commonClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get commonClear;

  /// No description provided for @commonProductCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 produit} =1{1 produit} other{{count} produits}}'**
  String commonProductCount(int count);

  /// No description provided for @commonArticleCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 article} =1{1 article} other{{count} articles}}'**
  String commonArticleCount(int count);

  /// No description provided for @commonNoResultsFor.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour « {query} »'**
  String commonNoResultsFor(Object query);

  /// No description provided for @apiBackendNotConfiguredTitle.
  ///
  /// In fr, this message translates to:
  /// **'API backend non configurée'**
  String get apiBackendNotConfiguredTitle;

  /// No description provided for @apiBackendNotConfiguredMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez HEYN_API_BASE_URL avec l\'URL du backend Django pour charger les données réelles.'**
  String get apiBackendNotConfiguredMessage;

  /// No description provided for @apiBackendUnavailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au backend impossible'**
  String get apiBackendUnavailableTitle;

  /// No description provided for @apiBackendUnavailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez la connexion ou la disponibilité du backend.'**
  String get apiBackendUnavailableMessage;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get navCategories;

  /// No description provided for @navCart.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In fr, this message translates to:
  /// **'Mes commandes'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @authSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get authSkip;

  /// No description provided for @authWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue chez Heyn'**
  String get authWelcome;

  /// No description provided for @authContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get authContinue;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccount;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre numéro de téléphone pour suivre vos commandes'**
  String get authWelcomeSubtitle;

  /// No description provided for @authClientType.
  ///
  /// In fr, this message translates to:
  /// **'Type de client'**
  String get authClientType;

  /// No description provided for @authPhoneNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get authPhoneNumber;

  /// No description provided for @authEnterPhone.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre numéro'**
  String get authEnterPhone;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authYourPassword.
  ///
  /// In fr, this message translates to:
  /// **'Votre mot de passe'**
  String get authYourPassword;

  /// No description provided for @authShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get authHidePassword;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgotPasswordLink;

  /// No description provided for @authVerificationCodeLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec un code de vérification'**
  String get authVerificationCodeLogin;

  /// No description provided for @authOr.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get authOr;

  /// No description provided for @authCreateNewAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un nouveau compte'**
  String get authCreateNewAccount;

  /// No description provided for @authLegalText.
  ///
  /// In fr, this message translates to:
  /// **'En continuant, vous acceptez les conditions d\'utilisation et la politique de confidentialité.'**
  String get authLegalText;

  /// No description provided for @authNewToHeyn.
  ///
  /// In fr, this message translates to:
  /// **'Vous découvrez Heyn ?'**
  String get authNewToHeyn;

  /// No description provided for @authCreateYourAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer votre compte'**
  String get authCreateYourAccount;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez Heyn pour commander vos produits du quotidien.'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get authFullName;

  /// No description provided for @authShopName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la boutique'**
  String get authShopName;

  /// No description provided for @authConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get authConfirmPassword;

  /// No description provided for @authCreateMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get authCreateMyAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLogin;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez l\'email de votre compte. En local, le lien s\'affiche dans le terminal de npm run dev.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authResetLinkSent.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe avec cet email, un lien de réinitialisation vient d\'être envoyé.'**
  String get authResetLinkSent;

  /// No description provided for @authSendResetLink.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get authSendResetLink;

  /// No description provided for @authAlreadyHaveCode.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un code'**
  String get authAlreadyHaveCode;

  /// No description provided for @authNewPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get authNewPasswordTitle;

  /// No description provided for @authNewPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Collez le code du lien (paramètre token). Le mot de passe doit avoir au moins 8 caractères.'**
  String get authNewPasswordSubtitle;

  /// No description provided for @authCodeToken.
  ///
  /// In fr, this message translates to:
  /// **'Code / token'**
  String get authCodeToken;

  /// No description provided for @authNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get authNewPassword;

  /// No description provided for @authConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get authConfirm;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé. Connectez-vous.'**
  String get authPasswordResetSuccess;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants incorrects.'**
  String get authInvalidCredentials;

  /// No description provided for @authEnterFullNameError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez votre nom complet.'**
  String get authEnterFullNameError;

  /// No description provided for @authEnterMauritanianPhoneError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez un numéro mauritanien à 8 chiffres.'**
  String get authEnterMauritanianPhoneError;

  /// No description provided for @authPasswordsMismatchError.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas.'**
  String get authPasswordsMismatchError;

  /// No description provided for @authEnterShopNameError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez le nom de votre boutique.'**
  String get authEnterShopNameError;

  /// No description provided for @authPasswordMinEightError.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères.'**
  String get authPasswordMinEightError;

  /// No description provided for @authEnterFirstLastNameError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez votre nom et prénom.'**
  String get authEnterFirstLastNameError;

  /// No description provided for @authCreateAccountError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer le compte.'**
  String get authCreateAccountError;

  /// No description provided for @authPasswordMinSixError.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 6 caractères.'**
  String get authPasswordMinSixError;

  /// No description provided for @authPhoneAlreadyUsedError.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro est déjà utilisé.'**
  String get authPhoneAlreadyUsedError;

  /// No description provided for @authInvalidEmailError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez une adresse email valide.'**
  String get authInvalidEmailError;

  /// No description provided for @authServerUnavailableError.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur Heyen n\'est pas disponible.'**
  String get authServerUnavailableError;

  /// No description provided for @authSendLinkError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'envoyer le lien.'**
  String get authSendLinkError;

  /// No description provided for @authPasteEmailCodeError.
  ///
  /// In fr, this message translates to:
  /// **'Collez le code reçu par email (ou dans la console du serveur).'**
  String get authPasteEmailCodeError;

  /// No description provided for @authResetPasswordError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de réinitialiser le mot de passe.'**
  String get authResetPasswordError;

  /// No description provided for @guestPhoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quel est votre numéro ?'**
  String get guestPhoneTitle;

  /// No description provided for @guestPhoneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'On vérifiera si vous avez déjà un compte Heyn'**
  String get guestPhoneSubtitle;

  /// No description provided for @guestEditPhone.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le numéro'**
  String get guestEditPhone;

  /// No description provided for @guestPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre mot de passe'**
  String get guestPasswordTitle;

  /// No description provided for @guestNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? '**
  String get guestNoAccount;

  /// No description provided for @homeBannerEssentialsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stockez vos essentiels'**
  String get homeBannerEssentialsTitle;

  /// No description provided for @homeBannerWholesaleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gros et détail en un geste'**
  String get homeBannerWholesaleTitle;

  /// No description provided for @homeBannerDeliveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livraison à Nouakchott'**
  String get homeBannerDeliveryTitle;

  /// No description provided for @homeBannerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Prix pro sur tout le catalogue'**
  String get homeBannerSubtitle;

  /// No description provided for @homeBannerCta.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get homeBannerCta;

  /// No description provided for @homePopularThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Populaires cette semaine'**
  String get homePopularThisWeek;

  /// No description provided for @homeCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get homeCategories;

  /// No description provided for @homeNoCategories.
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie disponible pour le moment'**
  String get homeNoCategories;

  /// No description provided for @homeDeliveryTo.
  ///
  /// In fr, this message translates to:
  /// **'Livraison à'**
  String get homeDeliveryTo;

  /// No description provided for @homeDefaultAddress.
  ///
  /// In fr, this message translates to:
  /// **'Tevragh Zeina, Nouakchott'**
  String get homeDefaultAddress;

  /// No description provided for @homeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir, {firstName}'**
  String homeGreeting(Object firstName);

  /// No description provided for @homeWelcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour parmi nous'**
  String get homeWelcomeBack;

  /// No description provided for @homeNoProducts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit disponible pour le moment'**
  String get homeNoProducts;

  /// No description provided for @homeSeeCategoryProducts.
  ///
  /// In fr, this message translates to:
  /// **'Voir tous les produits de cette catégorie'**
  String get homeSeeCategoryProducts;

  /// No description provided for @homeSeeCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout le catalogue'**
  String get homeSeeCatalog;

  /// No description provided for @homeOtherProducts.
  ///
  /// In fr, this message translates to:
  /// **'Autres produits'**
  String get homeOtherProducts;

  /// No description provided for @catalogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue Heyn'**
  String get catalogTitle;

  /// No description provided for @catalogShopByCategory.
  ///
  /// In fr, this message translates to:
  /// **'Achetez par catégorie'**
  String get catalogShopByCategory;

  /// No description provided for @catalogCategorySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un produit de cette catégorie.'**
  String get catalogCategorySubtitle;

  /// No description provided for @catalogMerchantSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Prix de gros pour l\'approvisionnement de votre commerce.'**
  String get catalogMerchantSubtitle;

  /// No description provided for @catalogRetailSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Parcourez les catégories et ajoutez vos produits au panier.'**
  String get catalogRetailSubtitle;

  /// No description provided for @catalogDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get catalogDelivery;

  /// No description provided for @catalogFilterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer le catalogue'**
  String get catalogFilterTitle;

  /// No description provided for @catalogFilterAllProducts.
  ///
  /// In fr, this message translates to:
  /// **'Tous les produits'**
  String get catalogFilterAllProducts;

  /// No description provided for @catalogFilterAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponibles'**
  String get catalogFilterAvailable;

  /// No description provided for @catalogFilterPromotions.
  ///
  /// In fr, this message translates to:
  /// **'Promotions'**
  String get catalogFilterPromotions;

  /// No description provided for @catalogFilterPriceAsc.
  ///
  /// In fr, this message translates to:
  /// **'Prix croissant'**
  String get catalogFilterPriceAsc;

  /// No description provided for @catalogFilterPriceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Prix décroissant'**
  String get catalogFilterPriceDesc;

  /// No description provided for @productDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail produit'**
  String get productDetailTitle;

  /// No description provided for @productGenericTitle.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get productGenericTitle;

  /// No description provided for @productUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit n\'est plus dans le catalogue Heyn.'**
  String get productUnavailable;

  /// No description provided for @productOutOfStock.
  ///
  /// In fr, this message translates to:
  /// **'Produit en rupture de stock'**
  String get productOutOfStock;

  /// No description provided for @productAddedToCart.
  ///
  /// In fr, this message translates to:
  /// **'{productName} ajouté au panier'**
  String productAddedToCart(Object productName);

  /// No description provided for @productCopied.
  ///
  /// In fr, this message translates to:
  /// **'Produit copié dans le presse-papiers'**
  String get productCopied;

  /// No description provided for @productDetails.
  ///
  /// In fr, this message translates to:
  /// **'Description du produit'**
  String get productDetails;

  /// No description provided for @productQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get productQuantity;

  /// No description provided for @productSimilarProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits similaires'**
  String get productSimilarProducts;

  /// No description provided for @productDetailStockAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get productDetailStockAvailable;

  /// No description provided for @productDetailStockLimited.
  ///
  /// In fr, this message translates to:
  /// **'Quantité limitée'**
  String get productDetailStockLimited;

  /// No description provided for @productDetailStockOut.
  ///
  /// In fr, this message translates to:
  /// **'Rupture de stock'**
  String get productDetailStockOut;

  /// No description provided for @productAddToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get productAddToCart;

  /// No description provided for @productOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get productOrder;

  /// No description provided for @productStockOut.
  ///
  /// In fr, this message translates to:
  /// **'Rupture de stock'**
  String get productStockOut;

  /// No description provided for @productStockOutShort.
  ///
  /// In fr, this message translates to:
  /// **'Rupture'**
  String get productStockOutShort;

  /// No description provided for @productStockLimited.
  ///
  /// In fr, this message translates to:
  /// **'Stock limité'**
  String get productStockLimited;

  /// No description provided for @productAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get productAvailable;

  /// No description provided for @productPromo.
  ///
  /// In fr, this message translates to:
  /// **'Promo'**
  String get productPromo;

  /// No description provided for @productNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get productNew;

  /// No description provided for @productWholesalePrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix gros'**
  String get productWholesalePrice;

  /// No description provided for @cartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get cartTitle;

  /// No description provided for @cartMerchantSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tarifs professionnels, panier type hebdomadaire et devis avant commande.'**
  String get cartMerchantSubtitle;

  /// No description provided for @cartRetailSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos lignes de commande avant validation et votre réapprovisionnement.'**
  String get cartRetailSubtitle;

  /// No description provided for @cartContinueQuote.
  ///
  /// In fr, this message translates to:
  /// **'Continuer vers le devis'**
  String get cartContinueQuote;

  /// No description provided for @cartPlaceOrder.
  ///
  /// In fr, this message translates to:
  /// **'Passer la commande'**
  String get cartPlaceOrder;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des produits depuis le catalogue pour préparer une commande.'**
  String get cartEmptySubtitle;

  /// No description provided for @cartSeeCategories.
  ///
  /// In fr, this message translates to:
  /// **'Voir les catégories'**
  String get cartSeeCategories;

  /// No description provided for @cartWeeklyTemplateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Panier type hebdomadaire'**
  String get cartWeeklyTemplateTitle;

  /// No description provided for @cartWeeklyTemplateSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegardez les produits rachetés chaque semaine, puis rechargez-les en un tap.'**
  String get cartWeeklyTemplateSubtitle;

  /// No description provided for @cartNoTemplate.
  ///
  /// In fr, this message translates to:
  /// **'Aucun panier type enregistré pour le moment.'**
  String get cartNoTemplate;

  /// No description provided for @cartTemplateSaved.
  ///
  /// In fr, this message translates to:
  /// **'Panier type enregistré.'**
  String get cartTemplateSaved;

  /// No description provided for @cartSubtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get cartSubtotal;

  /// No description provided for @cartDeliveryFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de livraison'**
  String get cartDeliveryFee;

  /// No description provided for @cartFinalTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total final'**
  String get cartFinalTotal;

  /// No description provided for @cartCouponHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code promo'**
  String get cartCouponHint;

  /// No description provided for @cartApplyCoupon.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get cartApplyCoupon;

  /// No description provided for @cartFreeDeliveryHint.
  ///
  /// In fr, this message translates to:
  /// **'Livraison gratuite pour les commandes de plus de MRU 10,000'**
  String get cartFreeDeliveryHint;

  /// No description provided for @checkoutShopExample.
  ///
  /// In fr, this message translates to:
  /// **'Epicerie Al Amal'**
  String get checkoutShopExample;

  /// No description provided for @checkoutSubmitQuote.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande de devis'**
  String get checkoutSubmitQuote;

  /// No description provided for @checkoutConfirmAndPay.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer et payer'**
  String get checkoutConfirmAndPay;

  /// No description provided for @checkoutDeliveryAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de livraison'**
  String get checkoutDeliveryAddress;

  /// No description provided for @checkoutDeliveryTime.
  ///
  /// In fr, this message translates to:
  /// **'Créneau de livraison'**
  String get checkoutDeliveryTime;

  /// No description provided for @checkoutToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get checkoutToday;

  /// No description provided for @checkoutTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get checkoutTomorrow;

  /// No description provided for @checkoutTimeWindowToday.
  ///
  /// In fr, this message translates to:
  /// **'9:00 - 12:00'**
  String get checkoutTimeWindowToday;

  /// No description provided for @checkoutTimeWindowTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'16:00 - 19:00'**
  String get checkoutTimeWindowTomorrow;

  /// No description provided for @checkoutPaymentCashOnDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Payez le livreur à l\'arrivée'**
  String get checkoutPaymentCashOnDelivery;

  /// No description provided for @checkoutNotesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notes au livreur'**
  String get checkoutNotesTitle;

  /// No description provided for @checkoutNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Exemple : appelez-moi à l\'arrivée'**
  String get checkoutNotesHint;

  /// No description provided for @checkoutCompleteLocationError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez un quartier et un repère de livraison.'**
  String get checkoutCompleteLocationError;

  /// No description provided for @checkoutPhoneError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez votre numéro de téléphone.'**
  String get checkoutPhoneError;

  /// No description provided for @checkoutPaymentMethodError.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un mode de paiement.'**
  String get checkoutPaymentMethodError;

  /// No description provided for @checkoutWalletPhoneError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez le numéro du compte mobile.'**
  String get checkoutWalletPhoneError;

  /// No description provided for @checkoutShopNameError.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez le nom de la boutique.'**
  String get checkoutShopNameError;

  /// No description provided for @checkoutQuoteSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devis envoyé'**
  String get checkoutQuoteSentTitle;

  /// No description provided for @checkoutOrderConfirmedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande confirmée'**
  String get checkoutOrderConfirmedTitle;

  /// No description provided for @checkoutOrderSuccessSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous vous contacterons par téléphone avant l\'arrivée du livreur.'**
  String get checkoutOrderSuccessSubtitle;

  /// No description provided for @checkoutQuoteSuccessSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Notre équipe vous contactera pour valider le devis.'**
  String get checkoutQuoteSuccessSubtitle;

  /// No description provided for @checkoutOrderNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de commande'**
  String get checkoutOrderNumber;

  /// No description provided for @checkoutExpectedDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison prévue'**
  String get checkoutExpectedDelivery;

  /// No description provided for @checkoutFinalAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant final'**
  String get checkoutFinalAmount;

  /// No description provided for @checkoutTrackOrder.
  ///
  /// In fr, this message translates to:
  /// **'Suivre la commande'**
  String get checkoutTrackOrder;

  /// No description provided for @checkoutSendInvoiceWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la facture via WhatsApp'**
  String get checkoutSendInvoiceWhatsApp;

  /// No description provided for @checkoutReturnHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get checkoutReturnHome;

  /// No description provided for @checkoutQuoteWhatsAppBody.
  ///
  /// In fr, this message translates to:
  /// **'Le devis {reference} est enregistré et lié au {phone} ({clientType}). Un message WhatsApp est prêt pour le service client.'**
  String checkoutQuoteWhatsAppBody(
    Object reference,
    Object phone,
    Object clientType,
  );

  /// No description provided for @checkoutOrderWhatsAppBody.
  ///
  /// In fr, this message translates to:
  /// **'La commande {reference} est enregistrée et liée au {phone} ({clientType}). Un message WhatsApp est prêt pour le service client.'**
  String checkoutOrderWhatsAppBody(
    Object reference,
    Object phone,
    Object clientType,
  );

  /// No description provided for @checkoutQuoteHeaderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devis gros avant commande'**
  String get checkoutQuoteHeaderTitle;

  /// No description provided for @checkoutOrderHeaderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer votre commande'**
  String get checkoutOrderHeaderTitle;

  /// No description provided for @checkoutQuoteHeaderSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Demande de devis'**
  String get checkoutQuoteHeaderSubtitle;

  /// No description provided for @checkoutOrderHeaderSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Checkout'**
  String get checkoutOrderHeaderSubtitle;

  /// No description provided for @deliveryLocationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quartier et repère'**
  String get deliveryLocationTitle;

  /// No description provided for @deliveryLocationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouakchott n\'a pas d\'adressage formel fiable. Choisissez un quartier.'**
  String get deliveryLocationSubtitle;

  /// No description provided for @deliveryLandmark.
  ///
  /// In fr, this message translates to:
  /// **'Repère'**
  String get deliveryLandmark;

  /// No description provided for @deliveryPhoneNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get deliveryPhoneNumber;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode Paiement'**
  String get paymentMethodTitle;

  /// No description provided for @paymentMethodSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez votre mode de paiement et confirmez.'**
  String get paymentMethodSubtitle;

  /// No description provided for @ordersQuotesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devis'**
  String get ordersQuotesTitle;

  /// No description provided for @ordersHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get ordersHistoryTitle;

  /// No description provided for @ordersNoOrders.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande pour le moment'**
  String get ordersNoOrders;

  /// No description provided for @ordersCurrentTab.
  ///
  /// In fr, this message translates to:
  /// **'Commandes en cours'**
  String get ordersCurrentTab;

  /// No description provided for @ordersPreviousTab.
  ///
  /// In fr, this message translates to:
  /// **'Commandes précédentes'**
  String get ordersPreviousTab;

  /// No description provided for @ordersNoCurrentOrders.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande en cours'**
  String get ordersNoCurrentOrders;

  /// No description provided for @ordersNoPreviousOrders.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande précédente'**
  String get ordersNoPreviousOrders;

  /// No description provided for @ordersViewDetails.
  ///
  /// In fr, this message translates to:
  /// **'Voir les détails'**
  String get ordersViewDetails;

  /// No description provided for @ordersReorder.
  ///
  /// In fr, this message translates to:
  /// **'Recommander'**
  String get ordersReorder;

  /// No description provided for @ordersDetailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détails de la commande'**
  String get ordersDetailsTitle;

  /// No description provided for @ordersHeaderMerchantTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devis et commandes'**
  String get ordersHeaderMerchantTitle;

  /// No description provided for @ordersHeaderRetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des commandes'**
  String get ordersHeaderRetailTitle;

  /// No description provided for @ordersHeaderMerchantSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les devis gros attendent la validation admin, puis le paiement mobile.'**
  String get ordersHeaderMerchantSubtitle;

  /// No description provided for @ordersHeaderRetailSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Commandes livrées, en cours, et confirmations WhatsApp.'**
  String get ordersHeaderRetailSubtitle;

  /// No description provided for @ordersNoQuotes.
  ///
  /// In fr, this message translates to:
  /// **'Aucun devis pour le moment'**
  String get ordersNoQuotes;

  /// No description provided for @ordersRejectQuote.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get ordersRejectQuote;

  /// No description provided for @ordersApproveQuote.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get ordersApproveQuote;

  /// No description provided for @ordersPayAndConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Payer et confirmer'**
  String get ordersPayAndConfirm;

  /// No description provided for @ordersPaymentConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Paiement {paymentMethod} confirmé. WhatsApp notifié.'**
  String ordersPaymentConfirmed(Object paymentMethod);

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsOrderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande {reference}'**
  String notificationsOrderTitle(Object reference);

  /// No description provided for @notificationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification pour le moment.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsSeeOrders.
  ///
  /// In fr, this message translates to:
  /// **'Voir les commandes'**
  String get notificationsSeeOrders;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte et préférences'**
  String get profileSubtitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get profilePersonalInfo;

  /// No description provided for @profileEditInformation.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les informations'**
  String get profileEditInformation;

  /// No description provided for @profileShop.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get profileShop;

  /// No description provided for @profileAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Adresses'**
  String get profileAddresses;

  /// No description provided for @profileRegisteredAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Adresses enregistrées'**
  String get profileRegisteredAddresses;

  /// No description provided for @profilePaymentMethods.
  ///
  /// In fr, this message translates to:
  /// **'Moyens de paiement'**
  String get profilePaymentMethods;

  /// No description provided for @profileSavedMonthlyCart.
  ///
  /// In fr, this message translates to:
  /// **'Panier mensuel enregistré'**
  String get profileSavedMonthlyCart;

  /// No description provided for @profileHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get profileHelp;

  /// No description provided for @profileHelpAndSupport.
  ///
  /// In fr, this message translates to:
  /// **'Aide et support'**
  String get profileHelpAndSupport;

  /// No description provided for @profileSupport.
  ///
  /// In fr, this message translates to:
  /// **'Support Heyn'**
  String get profileSupport;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogout;

  /// No description provided for @profileLogoutAction.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogoutAction;

  /// No description provided for @profileNoAddress.
  ///
  /// In fr, this message translates to:
  /// **'Aucune adresse enregistrée pour le moment.'**
  String get profileNoAddress;

  /// No description provided for @profileNoProfile.
  ///
  /// In fr, this message translates to:
  /// **'Aucun profil disponible pour le moment'**
  String get profileNoProfile;

  /// No description provided for @profileWhatsAppUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Le canal WhatsApp n\'est pas configuré sur cet appareil. Contactez le service client Heyn pour obtenir de l\'aide.'**
  String get profileWhatsAppUnavailable;

  /// No description provided for @profileWhatsAppLine.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp : {phone}'**
  String profileWhatsAppLine(Object phone);

  /// No description provided for @clientTypeIndividual.
  ///
  /// In fr, this message translates to:
  /// **'Particulier'**
  String get clientTypeIndividual;

  /// No description provided for @clientTypeMerchant.
  ///
  /// In fr, this message translates to:
  /// **'Commerçant'**
  String get clientTypeMerchant;

  /// No description provided for @clientTypeIndividualDescription.
  ///
  /// In fr, this message translates to:
  /// **'Compte personnel'**
  String get clientTypeIndividualDescription;

  /// No description provided for @clientTypeMerchantDescription.
  ///
  /// In fr, this message translates to:
  /// **'Compte commerçant'**
  String get clientTypeMerchantDescription;

  /// No description provided for @paymentBankily.
  ///
  /// In fr, this message translates to:
  /// **'Bankily'**
  String get paymentBankily;

  /// No description provided for @paymentMasrivi.
  ///
  /// In fr, this message translates to:
  /// **'Masrivi'**
  String get paymentMasrivi;

  /// No description provided for @paymentSedad.
  ///
  /// In fr, this message translates to:
  /// **'Sedad'**
  String get paymentSedad;

  /// No description provided for @paymentCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get paymentCash;

  /// No description provided for @paymentBankilyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Paiement mobile Bankily'**
  String get paymentBankilyDescription;

  /// No description provided for @paymentMasriviDescription.
  ///
  /// In fr, this message translates to:
  /// **'Paiement mobile Masrivi'**
  String get paymentMasriviDescription;

  /// No description provided for @paymentSedadDescription.
  ///
  /// In fr, this message translates to:
  /// **'Paiement mobile Sedad'**
  String get paymentSedadDescription;

  /// No description provided for @paymentCashDescription.
  ///
  /// In fr, this message translates to:
  /// **'Paiement en espèces'**
  String get paymentCashDescription;

  /// No description provided for @saleModeUnit.
  ///
  /// In fr, this message translates to:
  /// **'À l\'unité'**
  String get saleModeUnit;

  /// No description provided for @saleModeWholesale.
  ///
  /// In fr, this message translates to:
  /// **'En gros'**
  String get saleModeWholesale;

  /// No description provided for @saleModeBoth.
  ///
  /// In fr, this message translates to:
  /// **'Unité et gros'**
  String get saleModeBoth;

  /// No description provided for @saleModeUnitSuffix.
  ///
  /// In fr, this message translates to:
  /// **'/ unité'**
  String get saleModeUnitSuffix;

  /// No description provided for @saleModeWholesaleSuffix.
  ///
  /// In fr, this message translates to:
  /// **'/ gros'**
  String get saleModeWholesaleSuffix;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusDelivering.
  ///
  /// In fr, this message translates to:
  /// **'En livraison'**
  String get orderStatusDelivering;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get orderStatusDelivered;

  /// No description provided for @quoteStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente admin'**
  String get quoteStatusPending;

  /// No description provided for @quoteStatusApproved.
  ///
  /// In fr, this message translates to:
  /// **'Devis validé'**
  String get quoteStatusApproved;

  /// No description provided for @quoteStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Devis refusé'**
  String get quoteStatusRejected;

  /// No description provided for @whatsAppSupportMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour Heyn, j\'ai besoin d\'aide.'**
  String get whatsAppSupportMessage;

  /// No description provided for @whatsAppQuoteKind.
  ///
  /// In fr, this message translates to:
  /// **'devis'**
  String get whatsAppQuoteKind;

  /// No description provided for @whatsAppOrderKind.
  ///
  /// In fr, this message translates to:
  /// **'commande'**
  String get whatsAppOrderKind;

  /// No description provided for @whatsAppArticles.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get whatsAppArticles;

  /// No description provided for @whatsAppGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour Heyn'**
  String get whatsAppGreeting;

  /// No description provided for @whatsAppConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'confirmé'**
  String get whatsAppConfirmed;

  /// No description provided for @whatsAppProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get whatsAppProfile;

  /// No description provided for @whatsAppNeighborhood.
  ///
  /// In fr, this message translates to:
  /// **'Quartier'**
  String get whatsAppNeighborhood;

  /// No description provided for @whatsAppLandmark.
  ///
  /// In fr, this message translates to:
  /// **'Repère'**
  String get whatsAppLandmark;

  /// No description provided for @whatsAppPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get whatsAppPhone;

  /// No description provided for @whatsAppPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get whatsAppPayment;

  /// No description provided for @whatsAppTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get whatsAppTotal;

  /// No description provided for @categoryRice.
  ///
  /// In fr, this message translates to:
  /// **'Riz'**
  String get categoryRice;

  /// No description provided for @categoryRiceDescription.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les variétés de riz'**
  String get categoryRiceDescription;

  /// No description provided for @categoryOil.
  ///
  /// In fr, this message translates to:
  /// **'Huile'**
  String get categoryOil;

  /// No description provided for @categoryOilDescription.
  ///
  /// In fr, this message translates to:
  /// **'Huiles de cuisine et formats gros'**
  String get categoryOilDescription;

  /// No description provided for @categoryDates.
  ///
  /// In fr, this message translates to:
  /// **'Dattes'**
  String get categoryDates;

  /// No description provided for @categoryDatesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Dattes locales et importées'**
  String get categoryDatesDescription;

  /// No description provided for @categoryWater.
  ///
  /// In fr, this message translates to:
  /// **'Eau'**
  String get categoryWater;

  /// No description provided for @categoryWaterDescription.
  ///
  /// In fr, this message translates to:
  /// **'Eau minérale et packs'**
  String get categoryWaterDescription;

  /// No description provided for @categoryJuice.
  ///
  /// In fr, this message translates to:
  /// **'Jus'**
  String get categoryJuice;

  /// No description provided for @categoryJuiceDescription.
  ///
  /// In fr, this message translates to:
  /// **'Jus et boissons sucrées'**
  String get categoryJuiceDescription;

  /// No description provided for @categorySoap.
  ///
  /// In fr, this message translates to:
  /// **'Savon'**
  String get categorySoap;

  /// No description provided for @categorySoapDescription.
  ///
  /// In fr, this message translates to:
  /// **'Savons et hygiène quotidienne'**
  String get categorySoapDescription;

  /// No description provided for @categoryLaundry.
  ///
  /// In fr, this message translates to:
  /// **'Lessive'**
  String get categoryLaundry;

  /// No description provided for @categoryLaundryDescription.
  ///
  /// In fr, this message translates to:
  /// **'Lessives poudre et liquide'**
  String get categoryLaundryDescription;

  /// No description provided for @categoryDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get categoryDelivery;

  /// No description provided for @categoryDeliveryDescription.
  ///
  /// In fr, this message translates to:
  /// **'Articles populaires en livraison rapide'**
  String get categoryDeliveryDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
