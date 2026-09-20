import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecommerce_app/app/app.dart';
import 'package:ecommerce_app/core/api/api_config.dart';
import 'package:ecommerce_app/core/widgets/bottom_nav_bar.dart';
import 'package:ecommerce_app/features/orders/application/order_tracking_controller.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'app.localeCode': 'fr'});
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        orderStatusPollingEnabledProvider.overrideWithValue(false),
        apiConfigProvider.overrideWithValue(const ApiConfig(baseUrl: '')),
      ],
      child: const MyApp(),
    );
  }

  Finder textFieldByHint(String hint) {
    return find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == hint,
    );
  }

  Future<void> skipAuth(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('auth-skip')));
    await tester.pumpAndSettle();
  }

  Future<void> openLogin(WidgetTester tester) async {
    await tester.pumpAndSettle();
    if (find.text('Bienvenue chez Heyn').evaluate().isNotEmpty) {
      return;
    }
    await tester.tap(find.text('Panier').last);
    await tester.pumpAndSettle();
  }

  Future<void> openHome(WidgetTester tester) async {
    await tester.tap(find.text('Accueil').last);
    await tester.pumpAndSettle();
  }

  Future<void> submitLogin(
    WidgetTester tester, {
    required String phone,
    required String password,
  }) async {
    final sheetPhone = find.byKey(const Key('guest-auth-phone'));
    if (sheetPhone.evaluate().isNotEmpty) {
      await tester.enterText(sheetPhone, phone);
      await tester.pump();
      await tester.tap(find.byKey(const Key('guest-auth-continue')));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('guest-auth-password')),
        password,
      );
      await tester.pump();
      await tester.ensureVisible(find.text('Se connecter'));
      await tester.tap(find.text('Se connecter'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      return;
    }

    await tester.enterText(find.byKey(const Key('auth-phone')), phone);
    await tester.enterText(find.byKey(const Key('auth-password')), password);
    await tester.pump();
    await tester.ensureVisible(find.text('Se connecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se connecter'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  Future<void> submitOfficialRegister(
    WidgetTester tester, {
    required String name,
    required String phone,
    required String password,
  }) async {
    await tester.enterText(textFieldByHint('Nom complet'), name);
    await tester.enterText(textFieldByHint('+222 87654321'), phone);
    await tester.enterText(textFieldByHint('Mot de passe'), password);
    await tester.enterText(
      textFieldByHint('Confirmer le mot de passe'),
      password,
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer mon compte'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  Finder verticalScrollable(Key key) {
    return find
        .descendant(
          of: find.byKey(key),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          ),
        )
        .first;
  }

  testWidgets('first launch asks for language and persists the choice', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Choisissez votre langue'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-ar')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('language-continue')));
    await tester.pumpAndSettle();

    expect(find.text('مرحباً بك في هين'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app.localeCode'), 'ar');
  });

  testWidgets('app starts on login and Passer opens home as guest', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue chez Heyn'), findsOneWidget);
    expect(find.text('Tevragh Zeina, Nouakchott'), findsNothing);
    expect(find.byKey(const Key('auth-skip')), findsOneWidget);
    final skipSize = tester.getSize(find.byKey(const Key('auth-skip')));
    expect(skipSize.width, greaterThanOrEqualTo(44));
    expect(skipSize.height, greaterThanOrEqualTo(44));

    await skipAuth(tester);

    expect(find.text('Bienvenue chez Heyn'), findsNothing);
    expect(find.text('Tevragh Zeina, Nouakchott'), findsNothing);
    expect(find.textContaining('Bonsoir, Heyn'), findsNothing);
    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Panier'), findsOneWidget);
    expect(find.text('Mes commandes'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('Arabic login تخطي opens home as guest', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app.localeCode': 'ar'});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('مرحباً بك في هين'), findsOneWidget);
    expect(find.text('تخطي'), findsOneWidget);
    expect(find.byKey(const Key('auth-skip')), findsOneWidget);

    await skipAuth(tester);

    expect(find.text('مرحباً بك في هين'), findsNothing);
    expect(find.text('تفرغ زينة، نواكشوط'), findsNothing);
  });

  testWidgets('bottom nav keeps equal layout and logical taps in LTR and RTL', (
    WidgetTester tester,
  ) async {
    final tappedIndexes = <int>[];
    final items = const [
      BottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Accueil',
      ),
      BottomNavItem(
        icon: Icons.category_outlined,
        selectedIcon: Icons.category,
        label: 'Catégories',
      ),
      BottomNavItem(
        icon: Icons.shopping_cart_outlined,
        selectedIcon: Icons.shopping_cart,
        label: 'Panier',
      ),
      BottomNavItem(
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        label: 'Mes commandes',
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: 'Profil',
      ),
    ];

    Future<void> pumpNav(TextDirection direction) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: Scaffold(
              bottomNavigationBar: BottomNavBar(
                currentIndex: 0,
                cartCount: 3,
                items: items,
                onTap: tappedIndexes.add,
              ),
            ),
          ),
        ),
      );
    }

    await pumpNav(TextDirection.ltr);

    final ltrItemSizes = [
      for (final label in [
        'Accueil',
        'Catégories',
        'Panier',
        'Mes commandes',
        'Profil',
      ])
        tester.getSize(
          find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
        ),
    ];
    expect(ltrItemSizes.map((size) => size.height).toSet(), hasLength(1));
    expect(ltrItemSizes.map((size) => size.width).toSet(), hasLength(1));

    await pumpNav(TextDirection.rtl);
    await tester.tap(find.text('Accueil'));
    await tester.tap(find.text('Profil'));
    expect(tappedIndexes, [0, 4]);

    final homeCenter = tester.getCenter(find.text('Accueil'));
    final profileCenter = tester.getCenter(find.text('Profil'));
    expect(homeCenter.dx, greaterThan(profileCenter.dx));
  });

  testWidgets('guest can open catalog and product detail after Passer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await skipAuth(tester);

    await tester.tap(find.text('Catégories').last);
    await tester.pumpAndSettle();
    expect(find.text('Catalogue Heyn'), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-riz')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riz premium 5 kg'));
    await tester.pumpAndSettle();

    expect(find.text('Détail produit'), findsOneWidget);
    expect(find.text('Ajouter au panier'), findsOneWidget);
    expect(find.text('Commander'), findsOneWidget);
    expect(find.text('Bienvenue chez Heyn'), findsNothing);
  });

  testWidgets('guest can open product detail from the home product card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await skipAuth(tester);

    final homeScroll = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .first;

    await tester.scrollUntilVisible(
      find.byKey(const Key('home-product-riz-premium-5kg')),
      300,
      scrollable: homeScroll,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-product-riz-premium-5kg')));
    await tester.pumpAndSettle();

    expect(find.text('Détail produit'), findsOneWidget);
    expect(find.text('Riz premium 5 kg'), findsWidgets);
    expect(find.text('Bienvenue chez Heyn'), findsNothing);
  });

  testWidgets('guest category tile on home opens filtered catalog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await skipAuth(tester);

    final homeScroll = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .first;
    await tester.drag(homeScroll, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-category-riz-tap')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('catalog-back')), findsOneWidget);
    expect(find.text('5 produits'), findsOneWidget);
    expect(find.text('Riz premium 5 kg'), findsOneWidget);
    expect(find.text('Huile tournesol 1 L'), findsNothing);
  });

  testWidgets('guest cart tab opens login sheet and back returns', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await skipAuth(tester);

    await tester.tap(find.text('Catégories').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Panier').last);
    await tester.pumpAndSettle();

    expect(find.text('Quel est votre numéro ?'), findsOneWidget);
    expect(find.text('Bienvenue chez Heyn'), findsNothing);
    expect(find.text('Créer votre compte'), findsNothing);

    await tester.tap(find.byKey(const Key('login-back')));
    await tester.pumpAndSettle();

    expect(find.text('Quel est votre numéro ?'), findsNothing);
    expect(find.text('Bienvenue chez Heyn'), findsNothing);
    expect(find.text('Catalogue Heyn'), findsOneWidget);
  });

  testWidgets('Heyn login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    expect(find.text('Bienvenue chez Heyn'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(
      find.text('Se connecter avec un code de vérification'),
      findsOneWidget,
    );
    expect(find.text('Créer un nouveau compte'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
  });

  testWidgets('shows an error for invalid test credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    await submitLogin(tester, phone: '12345678', password: 'bad-password');

    expect(find.text('Identifiants incorrects.'), findsOneWidget);
  });

  testWidgets('Créer un nouveau compte opens the official register screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    await tester.ensureVisible(find.text('Créer un nouveau compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer un nouveau compte'));
    await tester.pumpAndSettle();

    expect(find.text('Créer votre compte'), findsOneWidget);
    expect(find.text('Nom complet'), findsOneWidget);
    expect(find.text('Particulier'), findsWidgets);
    expect(find.text('Commerçant'), findsWidgets);
    expect(find.text('Créer mon compte'), findsOneWidget);
    expect(find.byKey(const Key('auth-skip')), findsOneWidget);
  });

  testWidgets('verification code link opens the reset request screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    await tester.ensureVisible(
      find.text('Se connecter avec un code de vérification'),
    );
    await tester.tap(find.text('Se connecter avec un code de vérification'));
    await tester.pumpAndSettle();

    expect(find.text('Mot de passe oublié'), findsOneWidget);
    expect(find.text('Envoyer le lien'), findsOneWidget);
    await tester.tap(find.text('Envoyer le lien'));
    await tester.pumpAndSettle();
    expect(find.text('Indiquez une adresse email valide.'), findsOneWidget);
  });

  testWidgets('register creates a local account and opens the home shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    await tester.ensureVisible(find.text('Créer un nouveau compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer un nouveau compte'));
    await tester.pumpAndSettle();

    await submitOfficialRegister(
      tester,
      name: 'Fatima Sow',
      phone: '55555555',
      password: '123456',
    );
    await openHome(tester);

    expect(find.textContaining('Bonsoir, Fatima'), findsNothing);
    expect(find.text('Tevragh Zeina, Nouakchott'), findsNothing);
  });

  testWidgets('manual login opens the main shell for valid credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    await submitLogin(tester, phone: '12345678', password: '123456');
    await openHome(tester);

    expect(find.text('Tevragh Zeina, Nouakchott'), findsNothing);
    expect(find.textContaining('Bonsoir, Aminata'), findsNothing);
    expect(
      find.text('Populaires cette semaine', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Autres produits', skipOffstage: false), findsOneWidget);
    expect(find.text('Riz'), findsOneWidget);
    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Catégories'), findsWidgets);
    expect(find.text('Panier'), findsOneWidget);
    expect(find.text('Mes commandes'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  for (final phone in ['+22212345678', '+222 12345678']) {
    testWidgets('accepts normalized test phone $phone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await openLogin(tester);

      await submitLogin(tester, phone: phone, password: '123456');
      await openHome(tester);

      expect(find.text('Tevragh Zeina, Nouakchott'), findsNothing);
    });
  }

  testWidgets('seeded catalog supports product detail and cart updates', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await skipAuth(tester);

    await tester.tap(find.text('Catégories').last);
    await tester.pumpAndSettle();

    expect(find.text('Catalogue Heyn'), findsOneWidget);
    expect(find.text('Riz'), findsOneWidget);
    expect(find.text('Huile'), findsOneWidget);
    expect(find.text('Riz premium 5 kg'), findsNothing);

    await tester.tap(find.byKey(const Key('category-riz')));
    await tester.pumpAndSettle();

    expect(find.text('5 produits'), findsOneWidget);
    expect(find.text('Riz premium 5 kg'), findsOneWidget);
    expect(find.text('Riz brisé 25 kg'), findsOneWidget);
    expect(find.text('Huile tournesol 1 L'), findsNothing);

    await tester.tap(find.byKey(const Key('catalog-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category-huile')));
    await tester.pumpAndSettle();

    expect(find.text('4 produits'), findsOneWidget);
    expect(find.text('Huile tournesol 1 L'), findsOneWidget);
    expect(find.text('Huile de palme 5 L'), findsOneWidget);
    expect(find.text('Riz premium 5 kg'), findsNothing);

    await tester.tap(find.byKey(const Key('catalog-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category-riz')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riz premium 5 kg'));
    await tester.pumpAndSettle();

    expect(find.text('Détail produit'), findsOneWidget);
    expect(find.text('-10%'), findsOneWidget);
    expect(find.byKey(const Key('product-category')), findsOneWidget);
    expect(find.text('882 MRU'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('qty-plus')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('qty-plus')));
    await tester.pump();
    expect(find.text('1 764 MRU'), findsOneWidget);
    expect(find.text('882 MRU / unité'), findsOneWidget);

    await tester.tap(find.byKey(const Key('qty-minus')));
    await tester.pump();
    expect(find.text('882 MRU'), findsOneWidget);

    await tester.tap(find.byKey(const Key('product-category')));
    await tester.pumpAndSettle();
    expect(find.text('5 produits'), findsOneWidget);
    expect(find.text('Riz brisé 25 kg'), findsOneWidget);

    await tester.tap(find.text('Riz premium 5 kg'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ajouter au panier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter au panier'));
    await tester.pumpAndSettle();
    expect(find.text('Quel est votre numéro ?'), findsOneWidget);
    expect(find.text('Bienvenue chez Heyn'), findsNothing);
    expect(find.byKey(const Key('guest-auth-phone')), findsOneWidget);
    await submitLogin(tester, phone: '12345678', password: '123456');
    expect(find.text('Quel est votre numéro ?'), findsNothing);
    expect(find.text('Détail produit'), findsOneWidget);
    await tester.tap(find.text('Panier').last);
    await tester.pumpAndSettle();

    expect(find.text('Riz premium 5 kg'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('Total'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.byTooltip('Retirer'));
    await tester.pumpAndSettle();
    expect(find.text('Votre panier est vide'), findsOneWidget);
  });

  testWidgets(
    'seeded checkout confirms a local order with neighborhood and payment',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await openLogin(tester);

      await submitLogin(tester, phone: '12345678', password: '123456');
      await tester.tap(find.text('Catégories').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category-riz')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Riz premium 5 kg'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ajouter au panier'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter au panier'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Panier').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Passer la commande'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Passer la commande'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmer votre commande'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('checkout-landmark')),
        'Mosquée',
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('payment-bankily')),
        300,
        scrollable: verticalScrollable(const Key('checkout-scroll')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment-bankily')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('checkout-submit')),
        300,
        scrollable: verticalScrollable(const Key('checkout-scroll')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('checkout-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('checkout-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Commande confirmée'), findsOneWidget);
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();
      expect(find.text('Mes commandes'), findsWidgets);
      expect(find.text('Commandes en cours'), findsOneWidget);
      expect(find.text('Voir les détails'), findsWidgets);

      await tester.tap(find.text('Panier').last);
      await tester.pumpAndSettle();
      expect(find.text('Votre panier est vide'), findsOneWidget);
    },
  );

  testWidgets('seeded orders and profile are usable without API config', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    await submitLogin(tester, phone: '12345678', password: '123456');
    await tester.tap(find.text('Mes commandes').last);
    await tester.pumpAndSettle();

    expect(find.text('Mes commandes'), findsWidgets);
    expect(find.text('Commandes en cours'), findsOneWidget);
    expect(find.text('Commandes précédentes'), findsOneWidget);
    expect(find.text('CMD-1025'), findsOneWidget);
    expect(find.text('En préparation'), findsOneWidget);
    expect(find.text('Voir les détails'), findsOneWidget);
    expect(find.text('Recommander'), findsOneWidget);
    expect(find.text('En livraison'), findsNothing);
    expect(find.text('Livrée'), findsNothing);

    await tester.tap(find.text('Commandes précédentes'));
    await tester.pumpAndSettle();
    expect(find.text('CMD-1024'), findsOneWidget);
    expect(find.text('Livrée'), findsOneWidget);
    expect(find.text('2 x Riz premium 5 kg'), findsNothing);

    await tester.tap(find.text('Voir les détails'));
    await tester.pumpAndSettle();
    expect(find.text('Détails de la commande'), findsOneWidget);
    expect(find.text('2 x Riz premium 5 kg'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();

    expect(find.text('Aminata Diallo'), findsOneWidget);
    expect(find.text('Particulier'), findsWidgets);
    expect(find.text('Compte personnel'), findsOneWidget);
    expect(find.text('Tevragh Zeina, Nouakchott'), findsOneWidget);
  });

  testWidgets('merchant test login shows commerçant profile and orders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    await submitLogin(tester, phone: '87654321', password: '123456');
    await openHome(tester);

    expect(find.text('Marché capital, Nouakchott'), findsNothing);
    expect(find.textContaining('Bonsoir, Mohamed'), findsNothing);

    await tester.tap(find.text('Mes commandes').last);
    await tester.pumpAndSettle();

    expect(find.text('Mes commandes'), findsWidgets);
    expect(find.text('Commandes en cours'), findsOneWidget);
    expect(find.text('Commandes précédentes'), findsOneWidget);
    expect(find.text('CMD-2041'), findsOneWidget);

    await tester.tap(find.text('Commandes précédentes'));
    await tester.pumpAndSettle();
    expect(find.text('CMD-2040'), findsOneWidget);

    await tester.tap(find.text('Voir les détails'));
    await tester.pumpAndSettle();
    expect(find.text('10 x Riz premium 5 kg'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();

    expect(find.text('Mohamed Kane'), findsOneWidget);
    expect(find.text('Commerçant'), findsWidgets);
    expect(find.text('Compte commerçant'), findsOneWidget);
    expect(find.text('Epicerie Al Amal'), findsOneWidget);
  });

  testWidgets('merchant checkout requests a quote after loading weekly cart', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await openLogin(tester);

    await submitLogin(tester, phone: '87654321', password: '123456');
    await tester.tap(find.text('Catégories').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category-riz')));
    await tester.pumpAndSettle();

    expect(find.text('En gros'), findsWidgets);

    await tester.tap(find.text('Panier').last);
    await tester.pumpAndSettle();
    expect(find.text('Panier type hebdomadaire'), findsOneWidget);
    await tester.tap(find.text('Charger'));
    await tester.pumpAndSettle();
    expect(find.text('Riz premium 5 kg'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Continuer vers le devis'),
      400,
      scrollable: verticalScrollable(const Key('cart-scroll')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer vers le devis'));
    await tester.pumpAndSettle();

    expect(find.text('Devis gros avant commande'), findsOneWidget);
    expect(find.text('Nom de la boutique'), findsOneWidget);
    expect(find.text('Epicerie Al Amal'), findsWidgets);
    expect(find.text('Envoyer la demande de devis'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('checkout-landmark')),
      'Marché capital',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('checkout-submit')),
      300,
      scrollable: verticalScrollable(const Key('checkout-scroll')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('checkout-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Devis envoyé'), findsOneWidget);
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    expect(find.text('Mes commandes'), findsWidgets);
    expect(find.text('En attente admin'), findsOneWidget);
  });

  testWidgets(
    'Créer un compte from guest sheet opens full register and resumes action',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await skipAuth(tester);

      await tester.tap(find.text('Catégories').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category-riz')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Riz premium 5 kg'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ajouter au panier'));
      await tester.tap(find.text('Ajouter au panier'));
      await tester.pumpAndSettle();

      expect(find.text('Quel est votre numéro ?'), findsOneWidget);
      expect(find.text('Bienvenue ! Créons votre compte'), findsNothing);

      await tester.tap(find.byKey(const Key('guest-auth-create-account')));
      await tester.pumpAndSettle();

      expect(find.text('Créer votre compte'), findsOneWidget);
      expect(find.text('Quel est votre numéro ?'), findsNothing);
      expect(find.byKey(const Key('guest-auth-name')), findsNothing);

      await submitOfficialRegister(
        tester,
        name: 'Fatima Sow',
        phone: '55555555',
        password: '123456',
      );

      expect(find.text('Créer votre compte'), findsNothing);
      expect(find.text('Détail produit'), findsOneWidget);

      await tester.tap(find.text('Panier').last);
      await tester.pumpAndSettle();

      expect(find.text('Riz premium 5 kg'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    },
  );

  testWidgets(
    'unknown phone stays in the guest sheet and does not open register',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await skipAuth(tester);

      await tester.tap(find.text('Panier').last);
      await tester.pumpAndSettle();
      expect(find.text('Quel est votre numéro ?'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('guest-auth-phone')),
        '55555555',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('guest-auth-continue')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('guest-auth-password')),
        '123456',
      );
      await tester.pump();
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Identifiants incorrects.'), findsOneWidget);
      expect(find.text('Bienvenue ! Créons votre compte'), findsNothing);
      expect(find.byKey(const Key('guest-auth-name')), findsNothing);
      expect(find.byKey(const Key('guest-auth-password')), findsOneWidget);
      expect(find.text('Créer votre compte'), findsNothing);

      await tester.tap(find.byKey(const Key('guest-auth-create-account')));
      await tester.pumpAndSettle();

      expect(find.text('Créer votre compte'), findsOneWidget);
      expect(find.text('Nom complet'), findsOneWidget);
    },
  );
}
