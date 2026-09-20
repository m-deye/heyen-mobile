# Heyn — Application mobile d'approvisionnement 🇲🇷

Application Flutter de commande et de livraison pour **particuliers** et **commerçants** en Mauritanie.  
Heyn (Heyen) facilite l’approvisionnement quotidien à **Nouakchott** : catalogue, panier, checkout, suivi de commande, avec une interface en **français** et **arabe (RTL)**.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart)
![Riverpod](https://img.shields.io/badge/State-Riverpod-6C63FF)
![License](https://img.shields.io/badge/License-Proprietary-red)

---

## Idée du projet

Heyn est une application mobile d’**approvisionnement** pensée pour Nouakchott :

- les **particuliers** commandent les produits du quotidien (riz, lait, jus, huile, savon, etc.) ;
- les **commerçants** bénéficient de prix professionnels / gros et d’une demande de devis ;
- la livraison est locale (sélection de quartier, carte de Nouakchott) ;
- l’app est bilingue **FR / AR**, avec mise en page RTL pour l’arabe.

Le backend (catalogue, auth, commandes) est un projet **séparé**. Sans backend, l’app reste utilisable avec des **données de démo**.

---

## Fonctionnalités principales

- **Choix de langue au premier lancement** (français ou arabe), modifiable ensuite depuis le profil
- **Localisation FR / AR + RTL** via `gen-l10n` (`lib/l10n`)
- **Catalogue consultable sans compte** — navigation invité ; authentification à la demande (panier, profil, commandes)
- **Authentification** par numéro de téléphone mauritanien (`+222`) et mot de passe
- **Deux types de comptes** — Particulier et Commerçant (prix de gros pour les commerçants)
- **Catalogue et recherche** — catégories, grille produits, détail produit
- **Panier** — ajout, quantités, panier type hebdomadaire (enregistrer / charger)
- **Checkout** — quartier de livraison, méthode de paiement (Bankily, Masrivi, Sedad, espèces), demande de devis gros
- **Commandes** — suivi avec timeline : Confirmée → En préparation → En livraison → Livrée
- **Profil** — infos compte, langue, déconnexion
- **Thème Heyn** — charte officielle **navy** (`#0B2D5C`) et **turquoise** (`#1AA8B0`)

---

## Stack technique

| Couche | Technologie |
|---|---|
| **Framework** | Flutter 3.x / Dart ≥ 3.11 (`sdk: ^3.11.0` dans `pubspec.yaml`) |
| **State management** | flutter_riverpod 3.x |
| **Navigation** | go_router 17.x |
| **HTTP** | Dio 5.x |
| **Stockage local** | shared_preferences (session, langue) |
| **Internationalisation** | `flutter_localizations` + `gen-l10n` (`l10n.yaml`, ARB FR/AR) |
| **Typographie** | google_fonts (Inter) |
| **Couleurs officielles** | Navy `#0B2D5C` / Turquoise `#1AA8B0` (`HeynColors`) |
| **Backend (séparé)** | Next.js + Prisma + PostgreSQL — [m-deye/heyen](https://github.com/m-deye/heyen) |

---

## Prérequis

- **Flutter SDK** ≥ 3.11 ([installation](https://docs.flutter.dev/get-started/install))
- **Dart SDK** ≥ 3.11 (fourni avec Flutter)
- Un **émulateur Android** ou un **appareil physique** (USB / wireless)
- Vérifier l’environnement :

```bash
flutter doctor
flutter devices
```

`flutter doctor` doit indiquer un toolchain Android (ou iOS) valide avant `flutter run`.

---

## Installation et lancement (app mobile)

```bash
git clone https://github.com/m-deye/heyen-mobile.git
cd heyen-mobile

flutter pub get
flutter devices
flutter run
```

Scripts utiles :

```bash
dart analyze
flutter test
flutter build apk --release
flutter build ios --release   # macOS uniquement
```

Le dépôt GitHub affiche le **code source**, pas l’app en cours d’exécution. Pour voir les écrans, il faut lancer Flutter sur un émulateur ou un appareil.

---

## Connexion au backend

L’URL de l’API est lue via `--dart-define=HEYN_API_BASE_URL`.  
Si la variable n’est pas fournie, en **debug** l’app utilise :

| Cible | URL par défaut |
|---|---|
| Émulateur Android | `http://10.0.2.2:3000` |
| Desktop / iOS / Chrome | `http://127.0.0.1:3000` |

En **release**, aucune URL n’est définie tant que `HEYN_API_BASE_URL` n’est pas passé.

```bash
# Émulateur Android → API sur la machine hôte
flutter run --dart-define=HEYN_API_BASE_URL=http://10.0.2.2:3000

# Windows / iOS simulateur / Chrome → API locale
flutter run --dart-define=HEYN_API_BASE_URL=http://127.0.0.1:3000
```

Le backend est **un autre dépôt**, typiquement :

- local : `C:\Users\DELL\Downloads\heyen-main\heyen-main`
- GitHub : [https://github.com/m-deye/heyen](https://github.com/m-deye/heyen)

Stack backend : **Next.js + Prisma + PostgreSQL**. En développement :

```bash
# Dans le dossier backend
docker compose up -d
npx prisma migrate deploy
npm run prisma:seed
npm run dev                 # port 3000
```

**Si le backend est éteint**, l’app bascule sur des **données de démo** (catégories, produits, connexion test). L’interface reste la même.

Aucun secret n’est stocké dans ce dépôt. Ne commitez pas de fichier `.env`.

---

## Comptes de démo

Disponibles en mode local / démo (backend éteint ou seed local) :

| Type | Téléphone | Mot de passe |
|---|---|---|
| Particulier | `12345678` | `123456` |
| Commerçant | `87654321` | `123456` |

---

## Architecture

Organisation **feature-first** :

```
lib/
├── app/                    # Routes (GoRouter), shell, MaterialApp
├── core/
│   ├── api/                # Client Dio, HEYN_API_BASE_URL, tokens
│   ├── locale/             # Contrôleur de langue FR/AR
│   ├── theme/              # AppColors, AppTheme
│   └── widgets/            # Widgets partagés
├── features/
│   ├── onboarding/         # Écran de choix de langue
│   ├── auth/               # Login, register, guest, session
│   ├── home/               # Accueil (bannière, catégories, populaires)
│   ├── catalog/            # Catalogue, recherche
│   ├── products/           # Détail produit
│   ├── cart/               # Panier
│   ├── checkout/           # Livraison, paiement, devis
│   ├── orders/             # Suivi commandes
│   ├── notifications/      # Centre de notifications
│   └── profile/            # Profil, changement de langue
├── l10n/                   # ARB + AppLocalizations (gen-l10n)
├── shared/                 # Modèles, formatters, widgets communs
└── theme/                  # Charte Heyn (navy / turquoise)
```

Les traductions sources sont `lib/l10n/app_fr.arb` et `lib/l10n/app_ar.arb` (`flutter: generate: true` dans `pubspec.yaml`).

---

## Contributeurs

- **Mohamed Deye** — Développeur principal

---

## Licence

Projet propriétaire — tous droits réservés © 2026 Heyn.
