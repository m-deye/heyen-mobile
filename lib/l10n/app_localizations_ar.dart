// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Heyn';

  @override
  String get languageScreenTitle => 'اختر لغتك';

  @override
  String get languageScreenSubtitle => 'يمكنك تغييرها لاحقا من الملف الشخصي.';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrenchNative => 'Français';

  @override
  String get languageArabicNative => 'العربية';

  @override
  String get languageContinue => 'متابعة';

  @override
  String get languageChangeTitle => 'اللغة';

  @override
  String get languageCurrent => 'اللغة الحالية';

  @override
  String get languageUpdated => 'تم تحديث اللغة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonLoad => 'تحميل';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonAll => 'الكل';

  @override
  String get commonFilter => 'تصفية';

  @override
  String get commonSendWhatsApp => 'إرسال عبر واتساب';

  @override
  String get commonTotal => 'المجموع';

  @override
  String get commonRemove => 'إزالة';

  @override
  String get commonBackToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get commonSearchProduct => 'إبحث عن منتج...';

  @override
  String get commonClear => 'مسح';

  @override
  String commonProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      many: '$count منتجا',
      few: '$count منتجات',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: '0 منتج',
    );
    return '$_temp0';
  }

  @override
  String commonArticleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنف',
      many: '$count صنفا',
      few: '$count أصناف',
      two: 'صنفان',
      one: 'صنف واحد',
      zero: '0 صنف',
    );
    return '$_temp0';
  }

  @override
  String commonNoResultsFor(Object query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get apiBackendNotConfiguredTitle => 'واجهة الخادم غير مهيأة';

  @override
  String get apiBackendNotConfiguredMessage =>
      'أضف HEYN_API_BASE_URL مع رابط خادم Django لتحميل البيانات الحقيقية.';

  @override
  String get apiBackendUnavailableTitle => 'تعذر الاتصال بالخادم';

  @override
  String get apiBackendUnavailableMessage =>
      'تحقق من الاتصال أو من توفر الخادم.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'التصنيفات';

  @override
  String get navCart => 'السلة';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get navProfile => 'حسابي';

  @override
  String get authSkip => 'تخطي';

  @override
  String get authWelcome => 'مرحباً بك في هين';

  @override
  String get authContinue => 'متابعة';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authWelcomeSubtitle => 'أدخل رقم هاتفك لمتابعة طلباتك';

  @override
  String get authClientType => 'نوع العميل';

  @override
  String get authPhoneNumber => 'رقم الهاتف';

  @override
  String get authEnterPhone => 'أدخل رقمك';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authYourPassword => 'كلمة المرور';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authForgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get authVerificationCodeLogin => 'الدخول برمز التحقق';

  @override
  String get authOr => 'أو';

  @override
  String get authCreateNewAccount => 'إنشاء حساب جديد';

  @override
  String get authLegalText =>
      'بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية.';

  @override
  String get authNewToHeyn => 'هل تستخدم Heyn لأول مرة؟';

  @override
  String get authCreateYourAccount => 'أنشئ حسابك';

  @override
  String get authRegisterSubtitle => 'انضم إلى Heyn لطلب منتجاتك اليومية.';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authShopName => 'اسم المتجر';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authCreateMyAccount => 'إنشاء حسابي';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authForgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get authForgotPasswordSubtitle =>
      'أدخل البريد الإلكتروني لحسابك. في الوضع المحلي يظهر الرابط في طرفية npm run dev.';

  @override
  String get authResetLinkSent =>
      'إذا كان هناك حساب بهذا البريد، فقد تم إرسال رابط إعادة التعيين.';

  @override
  String get authSendResetLink => 'إرسال الرابط';

  @override
  String get authAlreadyHaveCode => 'لدي رمز بالفعل';

  @override
  String get authNewPasswordTitle => 'كلمة مرور جديدة';

  @override
  String get authNewPasswordSubtitle =>
      'الصق رمز الرابط (معامل token). يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.';

  @override
  String get authCodeToken => 'الرمز / token';

  @override
  String get authNewPassword => 'كلمة مرور جديدة';

  @override
  String get authConfirm => 'تأكيد';

  @override
  String get authPasswordResetSuccess =>
      'تمت إعادة تعيين كلمة المرور. سجل الدخول.';

  @override
  String get authInvalidCredentials => 'بيانات الدخول غير صحيحة.';

  @override
  String get authEnterFullNameError => 'أدخل اسمك الكامل.';

  @override
  String get authEnterMauritanianPhoneError =>
      'أدخل رقما موريتانيا من 8 أرقام.';

  @override
  String get authPasswordsMismatchError => 'كلمتا المرور غير متطابقتين.';

  @override
  String get authEnterShopNameError => 'أدخل اسم متجرك.';

  @override
  String get authPasswordMinEightError =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.';

  @override
  String get authEnterFirstLastNameError => 'أدخل الاسم واللقب.';

  @override
  String get authCreateAccountError => 'تعذر إنشاء الحساب.';

  @override
  String get authPasswordMinSixError =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get authPhoneAlreadyUsedError => 'هذا الرقم مستخدم بالفعل.';

  @override
  String get authInvalidEmailError => 'أدخل بريدا إلكترونيا صالحا.';

  @override
  String get authServerUnavailableError => 'خادم Heyen غير متاح.';

  @override
  String get authSendLinkError => 'تعذر إرسال الرابط.';

  @override
  String get authPasteEmailCodeError =>
      'الصق الرمز الذي وصلك بالبريد الإلكتروني (أو الموجود في طرفية الخادم).';

  @override
  String get authResetPasswordError => 'تعذر إعادة تعيين كلمة المرور.';

  @override
  String get guestPhoneTitle => 'ما رقم هاتفك؟';

  @override
  String get guestPhoneSubtitle => 'سنتحقق إن كان لديك حساب Heyn من قبل';

  @override
  String get guestEditPhone => 'تعديل الرقم';

  @override
  String get guestPasswordTitle => 'أدخل كلمة المرور';

  @override
  String get guestNoAccount => 'ليس لديك حساب بعد؟ ';

  @override
  String get homeBannerEssentialsTitle => 'وفر مستلزماتك الأساسية';

  @override
  String get homeBannerWholesaleTitle => 'الجملة والتجزئة بخطوة واحدة';

  @override
  String get homeBannerDeliveryTitle => 'توصيل داخل نواكشوط';

  @override
  String get homeBannerSubtitle => 'أسعار الجملة على كل الكتالوج';

  @override
  String get homeBannerCta => 'اطلب الآن';

  @override
  String get homePopularThisWeek => 'الأكثر طلبا هذا الأسبوع';

  @override
  String get homeCategories => 'التصنيفات';

  @override
  String get homeNoCategories => 'لا توجد فئات متاحة حاليا';

  @override
  String get homeDeliveryTo => 'التوصيل إلى';

  @override
  String get homeDefaultAddress => 'تفرغ زينة، نواكشوط';

  @override
  String homeGreeting(Object firstName) {
    return 'مساء الخير، $firstName';
  }

  @override
  String get homeWelcomeBack => 'سعداء بعودتك';

  @override
  String get homeNoProducts => 'لا توجد منتجات متاحة حاليا';

  @override
  String get homeSeeCategoryProducts => 'عرض كل منتجات هذه الفئة';

  @override
  String get homeSeeCatalog => 'عرض الكتالوج كاملا';

  @override
  String get homeOtherProducts => 'منتجات أخرى';

  @override
  String get catalogTitle => 'كتالوج Heyn';

  @override
  String get catalogShopByCategory => 'تسوق حسب التصنيف';

  @override
  String get catalogCategorySubtitle => 'اختر منتجا من هذه الفئة.';

  @override
  String get catalogMerchantSubtitle => 'أسعار جملة لتزويد متجرك.';

  @override
  String get catalogRetailSubtitle => 'تصفح الفئات وأضف منتجاتك إلى السلة.';

  @override
  String get catalogDelivery => 'التوصيل';

  @override
  String get catalogFilterTitle => 'تصفية الكتالوج';

  @override
  String get catalogFilterAllProducts => 'كل المنتجات';

  @override
  String get catalogFilterAvailable => 'المتاحة';

  @override
  String get catalogFilterPromotions => 'العروض';

  @override
  String get catalogFilterPriceAsc => 'السعر من الأقل إلى الأعلى';

  @override
  String get catalogFilterPriceDesc => 'السعر من الأعلى إلى الأقل';

  @override
  String get productDetailTitle => 'تفاصيل المنتج';

  @override
  String get productGenericTitle => 'منتج';

  @override
  String get productUnavailable => 'لم يعد هذا المنتج موجودا في كتالوج Heyn.';

  @override
  String get productOutOfStock => 'المنتج غير متوفر';

  @override
  String productAddedToCart(Object productName) {
    return 'تمت إضافة $productName إلى السلة';
  }

  @override
  String get productCopied => 'تم نسخ المنتج إلى الحافظة';

  @override
  String get productDetails => 'وصف المنتج';

  @override
  String get productQuantity => 'الكمية';

  @override
  String get productSimilarProducts => 'منتجات مشابهة';

  @override
  String get productDetailStockAvailable => 'متوفر';

  @override
  String get productDetailStockLimited => 'الكمية محدودة';

  @override
  String get productDetailStockOut => 'نفد المخزون';

  @override
  String get productAddToCart => 'إضافة إلى السلة';

  @override
  String get productOrder => 'اطلب';

  @override
  String get productStockOut => 'غير متوفر';

  @override
  String get productStockOutShort => 'غير متوفر';

  @override
  String get productStockLimited => 'كمية محدودة';

  @override
  String get productAvailable => 'متوفر';

  @override
  String get productPromo => 'عرض';

  @override
  String get productNew => 'جديد';

  @override
  String get productWholesalePrice => 'سعر الجملة';

  @override
  String get cartTitle => 'السلة';

  @override
  String get cartMerchantSubtitle =>
      'أسعار مهنية وسلة أسبوعية نموذجية وطلب عرض سعر قبل الطلب.';

  @override
  String get cartRetailSubtitle =>
      'راجع عناصر الطلب قبل التأكيد وإعادة التزويد.';

  @override
  String get cartContinueQuote => 'المتابعة إلى عرض السعر';

  @override
  String get cartPlaceOrder => 'إرسال الطلب';

  @override
  String get cartEmptyTitle => 'سلتك فارغة';

  @override
  String get cartEmptySubtitle => 'أضف منتجات من الكتالوج لتحضير طلبك.';

  @override
  String get cartSeeCategories => 'عرض الفئات';

  @override
  String get cartWeeklyTemplateTitle => 'سلة أسبوعية نموذجية';

  @override
  String get cartWeeklyTemplateSubtitle =>
      'احفظ المنتجات التي تعيد شراءها أسبوعيا ثم أعد تحميلها بلمسة واحدة.';

  @override
  String get cartNoTemplate => 'لا توجد سلة نموذجية محفوظة حاليا.';

  @override
  String get cartTemplateSaved => 'تم حفظ السلة النموذجية.';

  @override
  String get cartSubtotal => 'المجموع الفرعي';

  @override
  String get cartDeliveryFee => 'تكلفة التوصيل';

  @override
  String get cartFinalTotal => 'المجموع النهائي';

  @override
  String get cartCouponHint => 'أدخل رمز التخفيض';

  @override
  String get cartApplyCoupon => 'تطبيق';

  @override
  String get cartFreeDeliveryHint => 'التوصيل مجاني للطلبات فوق MRU 10,000';

  @override
  String get checkoutShopExample => 'Epicerie Al Amal';

  @override
  String get checkoutSubmitQuote => 'إرسال طلب عرض السعر';

  @override
  String get checkoutConfirmAndPay => 'تأكيد ودفع';

  @override
  String get checkoutDeliveryAddress => 'عنوان التوصيل';

  @override
  String get checkoutDeliveryTime => 'موعد التوصيل';

  @override
  String get checkoutToday => 'اليوم';

  @override
  String get checkoutTomorrow => 'غدا';

  @override
  String get checkoutTimeWindowToday => '9:00 - 12:00';

  @override
  String get checkoutTimeWindowTomorrow => '16:00 - 19:00';

  @override
  String get checkoutPaymentCashOnDelivery => 'ادفع للمندوب عند وصول الطلب';

  @override
  String get checkoutNotesTitle => 'ملاحظات للمندوب';

  @override
  String get checkoutNotesHint => 'مثال: اتصل بي عند الوصول';

  @override
  String get checkoutCompleteLocationError => 'أدخل الحي ونقطة مرجعية للتوصيل.';

  @override
  String get checkoutPhoneError => 'أدخل رقم هاتفك.';

  @override
  String get checkoutPaymentMethodError => 'اختر وسيلة الدفع.';

  @override
  String get checkoutWalletPhoneError => 'أدخل رقم حساب الدفع المحمول.';

  @override
  String get checkoutShopNameError => 'أدخل اسم المتجر.';

  @override
  String get checkoutQuoteSentTitle => 'تم إرسال عرض السعر';

  @override
  String get checkoutOrderConfirmedTitle => 'تم تأكيد الطلب';

  @override
  String get checkoutOrderSuccessSubtitle =>
      'سنتواصل معك هاتفيا قبل وصول المندوب.';

  @override
  String get checkoutQuoteSuccessSubtitle =>
      'سيتواصل فريقنا معك لتأكيد عرض السعر.';

  @override
  String get checkoutOrderNumber => 'رقم الطلب';

  @override
  String get checkoutExpectedDelivery => 'موعد التوصيل المتوقع';

  @override
  String get checkoutFinalAmount => 'المجموع النهائي';

  @override
  String get checkoutTrackOrder => 'تتبع الطلب';

  @override
  String get checkoutSendInvoiceWhatsApp => 'إرسال الفاتورة عبر WhatsApp';

  @override
  String get checkoutReturnHome => 'العودة إلى الرئيسية';

  @override
  String checkoutQuoteWhatsAppBody(
    Object reference,
    Object phone,
    Object clientType,
  ) {
    return 'تم حفظ عرض السعر $reference وربطه بالرقم $phone ($clientType). رسالة واتساب جاهزة لخدمة العملاء.';
  }

  @override
  String checkoutOrderWhatsAppBody(
    Object reference,
    Object phone,
    Object clientType,
  ) {
    return 'تم حفظ الطلب $reference وربطه بالرقم $phone ($clientType). رسالة واتساب جاهزة لخدمة العملاء.';
  }

  @override
  String get checkoutQuoteHeaderTitle => 'عرض سعر جملة قبل الطلب';

  @override
  String get checkoutOrderHeaderTitle => 'تأكيد طلبك';

  @override
  String get checkoutQuoteHeaderSubtitle => 'طلب عرض سعر';

  @override
  String get checkoutOrderHeaderSubtitle => 'الدفع';

  @override
  String get deliveryLocationTitle => 'الحي ونقطة مرجعية';

  @override
  String get deliveryLocationSubtitle =>
      'لا يوجد في نواكشوط نظام عنونة رسمي موثوق. اختر الحي.';

  @override
  String get deliveryLandmark => 'نقطة مرجعية';

  @override
  String get deliveryPhoneNumber => 'رقم الهاتف';

  @override
  String get paymentMethodTitle => 'وسيلة الدفع';

  @override
  String get paymentMethodSubtitle => 'اختر وسيلة الدفع ثم أكد.';

  @override
  String get ordersQuotesTitle => 'عروض الأسعار';

  @override
  String get ordersHistoryTitle => 'السجل';

  @override
  String get ordersNoOrders => 'لا توجد طلبات حاليا';

  @override
  String get ordersCurrentTab => 'الطلبات الحالية';

  @override
  String get ordersPreviousTab => 'الطلبات السابقة';

  @override
  String get ordersNoCurrentOrders => 'لا توجد طلبات حالية';

  @override
  String get ordersNoPreviousOrders => 'لا توجد طلبات سابقة';

  @override
  String get ordersViewDetails => 'عرض التفاصيل';

  @override
  String get ordersReorder => 'إعادة الطلب';

  @override
  String get ordersDetailsTitle => 'تفاصيل الطلب';

  @override
  String get ordersHeaderMerchantTitle => 'عروض الأسعار والطلبات';

  @override
  String get ordersHeaderRetailTitle => 'سجل الطلبات';

  @override
  String get ordersHeaderMerchantSubtitle =>
      'تنتظر عروض أسعار الجملة موافقة الإدارة ثم الدفع المحمول.';

  @override
  String get ordersHeaderRetailSubtitle =>
      'الطلبات المسلمة والجارية وتأكيدات واتساب.';

  @override
  String get ordersNoQuotes => 'لا توجد عروض أسعار حاليا';

  @override
  String get ordersRejectQuote => 'رفض';

  @override
  String get ordersApproveQuote => 'تأكيد';

  @override
  String get ordersPayAndConfirm => 'الدفع والتأكيد';

  @override
  String ordersPaymentConfirmed(Object paymentMethod) {
    return 'تم تأكيد دفع $paymentMethod. تم إشعار واتساب.';
  }

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String notificationsOrderTitle(Object reference) {
    return 'طلب $reference';
  }

  @override
  String get notificationsEmpty => 'لا توجد إشعارات حاليا.';

  @override
  String get notificationsSeeOrders => 'عرض الطلبات';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileSubtitle => 'الحساب والتفضيلات';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileEditInformation => 'تعديل المعلومات';

  @override
  String get profileShop => 'المتجر';

  @override
  String get profileAddresses => 'العناوين';

  @override
  String get profileRegisteredAddresses => 'العناوين المحفوظة';

  @override
  String get profilePaymentMethods => 'وسائل الدفع';

  @override
  String get profileSavedMonthlyCart => 'السلة الشهرية المحفوظة';

  @override
  String get profileHelp => 'المساعدة';

  @override
  String get profileHelpAndSupport => 'المساعدة والدعم';

  @override
  String get profileSupport => 'دعم Heyn';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileLogoutAction => 'تسجيل الخروج';

  @override
  String get profileNoAddress => 'لا يوجد عنوان محفوظ حاليا.';

  @override
  String get profileNoProfile => 'لا يوجد ملف شخصي متاح حاليا';

  @override
  String get profileWhatsAppUnavailable =>
      'قناة واتساب غير مهيأة على هذا الجهاز. تواصل مع خدمة عملاء Heyn للحصول على المساعدة.';

  @override
  String profileWhatsAppLine(Object phone) {
    return 'واتساب: $phone';
  }

  @override
  String get clientTypeIndividual => 'فرد';

  @override
  String get clientTypeMerchant => 'تاجر';

  @override
  String get clientTypeIndividualDescription => 'حساب شخصي';

  @override
  String get clientTypeMerchantDescription => 'حساب تاجر';

  @override
  String get paymentBankily => 'Bankily';

  @override
  String get paymentMasrivi => 'Masrivi';

  @override
  String get paymentSedad => 'Sedad';

  @override
  String get paymentCash => 'نقدا';

  @override
  String get paymentBankilyDescription => 'دفع محمول عبر Bankily';

  @override
  String get paymentMasriviDescription => 'دفع محمول عبر Masrivi';

  @override
  String get paymentSedadDescription => 'دفع محمول عبر Sedad';

  @override
  String get paymentCashDescription => 'الدفع نقدا';

  @override
  String get saleModeUnit => 'بالوحدة';

  @override
  String get saleModeWholesale => 'بالجملة';

  @override
  String get saleModeBoth => 'بالوحدة والجملة';

  @override
  String get saleModeUnitSuffix => '/ وحدة';

  @override
  String get saleModeWholesaleSuffix => '/ جملة';

  @override
  String get orderStatusConfirmed => 'مؤكد';

  @override
  String get orderStatusPreparing => 'قيد التحضير';

  @override
  String get orderStatusDelivering => 'قيد التوصيل';

  @override
  String get orderStatusDelivered => 'تم التسليم';

  @override
  String get quoteStatusPending => 'بانتظار الإدارة';

  @override
  String get quoteStatusApproved => 'تمت الموافقة على عرض السعر';

  @override
  String get quoteStatusRejected => 'تم رفض عرض السعر';

  @override
  String get whatsAppSupportMessage => 'مرحبا Heyn، أحتاج إلى مساعدة.';

  @override
  String get whatsAppQuoteKind => 'عرض السعر';

  @override
  String get whatsAppOrderKind => 'الطلب';

  @override
  String get whatsAppArticles => 'الأصناف';

  @override
  String get whatsAppGreeting => 'مرحبا Heyn';

  @override
  String get whatsAppConfirmed => 'تم تأكيده';

  @override
  String get whatsAppProfile => 'الملف';

  @override
  String get whatsAppNeighborhood => 'الحي';

  @override
  String get whatsAppLandmark => 'نقطة مرجعية';

  @override
  String get whatsAppPhone => 'الهاتف';

  @override
  String get whatsAppPayment => 'الدفع';

  @override
  String get whatsAppTotal => 'المجموع';

  @override
  String get categoryRice => 'الأرز';

  @override
  String get categoryRiceDescription => 'كل أنواع الأرز';

  @override
  String get categoryOil => 'الزيوت';

  @override
  String get categoryOilDescription => 'زيوت الطبخ وأحجام الجملة';

  @override
  String get categoryDates => 'التمور';

  @override
  String get categoryDatesDescription => 'تمور محلية ومستوردة';

  @override
  String get categoryWater => 'المياه';

  @override
  String get categoryWaterDescription => 'مياه معدنية وعبوات';

  @override
  String get categoryJuice => 'العصائر';

  @override
  String get categoryJuiceDescription => 'عصائر ومشروبات محلاة';

  @override
  String get categorySoap => 'الصابون';

  @override
  String get categorySoapDescription => 'صابون ونظافة يومية';

  @override
  String get categoryLaundry => 'مساحيق الغسيل';

  @override
  String get categoryLaundryDescription => 'مساحيق وسوائل الغسيل';

  @override
  String get categoryDelivery => 'التوصيل';

  @override
  String get categoryDeliveryDescription => 'منتجات شائعة للتوصيل السريع';
}
