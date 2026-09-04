# Heyn — Application mobile d'approvisionnement 🇲🇷

Application Flutter de commande et livraison pour particuliers et commerçants en Mauritanie, avec prix professionnels et livraison locale à Nouakchott.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart)
![Riverpod](https://img.shields.io/badge/State-Riverpod-6C63FF)
![License](https://img.shields.io/badge/License-Proprietary-red)

---

## Fonctionnalités

- **Catalogue consultable sans connexion** — navigation libre en mode invité avec bottom sheet d'authentification à la demande (panier, profil)
- **Deux types de comptes** — Particulier et Commerçant (prix de gros pour les commerçants)
- **Panier intelligent** — panier type hebdomadaire réutilisable (enregistrer / charger)
- **Demande de devis** pour les commandes en gros
- **Suivi de commande** avec timeline de statut : Confirmée → En préparation → En livraison → Livrée
- **Authentification** par numéro de téléphone (+222) et mot de passe
- **Sélection de quartier** avec carte interactive de Nouakchott
- **Thème Heyn** — charte graphique navy / turquoise / crème avec atmosphère premium

---

## Stack technique

| Couche | Technologie |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.11+ |
| **State management** | flutter_riverpod 3.x |
| **Navigation** | go_router 17.x |
| **HTTP** | Dio 5.x |
| **Typographie** | google_fonts (Inter) |
| **Stockage local** | shared_preferences |
| **Backend** | API Next.js séparée — Prisma + PostgreSQL ([dépôt backend](https://github.com/m-deye/heyen)) |

---

## Architecture

Organisation **feature-first** avec séparation nette des responsabilités :

```
lib/
├── app/                    # Routes (go_router), shell principal, point d'entrée
├── core/
│   ├── api/                # Client Dio, configuration API, gestion des tokens
│   ├── config/             # Feature flags, constantes globales
│   ├── dev/                # Outils de développement (mock data, debug)
│   ├── geo/                # Géolocalisation, quartiers de Nouakchott
│   ├── theme/              # AppColors, AppTextStyles, AppTheme (Material 3)
│   └── widgets/            # Widgets partagés (AppCard, ProductCard, StatusTimeline…)
├── features/
│   ├── auth/               # Authentification (login, register, guest sheet, session)
│   │   ├── application/    # Controllers, navigation post-auth
│   │   ├── data/           # API auth, token store
│   │   └── presentation/   # Écrans login, register, forgot/reset password
│   ├── home/               # Écran d'accueil (bannière, catégories, populaires)
│   ├── catalog/            # Catalogue par catégories, grille produits
│   ├── products/           # Détail produit (galerie, quantité, ajout panier)
│   ├── cart/               # Panier, panier type hebdomadaire
│   ├── checkout/           # Demande de devis, sélection quartier, paiement
│   ├── orders/             # Suivi commandes, timeline de statut
│   ├── notifications/      # Centre de notifications
│   └── profile/            # Profil utilisateur, déconnexion
├── shared/
│   ├── formatters/         # Formatage prix (MRU / Ouguiya)
│   ├── models/             # Modèles de données (Product, Category, Order…)
│   ├── services/           # Services partagés
│   └── widgets/            # Widgets communs (CategoryMedia, ProductHeroMedia…)
├── theme/                  # Charte Heyn (HeynColors, HeynTextStyles, HeynAtmosphere)
└── widgets/                # Widgets legacy
```

---

## Le dépôt GitHub n’est pas l’application

Ouvrir https://github.com/m-deye/heyen-mobile affiche le **code source**, pas l’app en cours d’exécution.  
Pour voir les écrans comme sur ton téléphone, il faut **cloner le projet et lancer Flutter** sur un émulateur ou un appareil.

Le dépôt doit être **public** (ou le visiteur ajouté comme collaborateur) pour qu’il puisse le cloner.

---

## Prérequis

- **Flutter SDK** ≥ 3.11 ([installation](https://docs.flutter.dev/get-started/install))
- **Dart SDK** ≥ 3.11 (inclus avec Flutter)
- Un appareil Android/iOS **ou** un émulateur configuré (`flutter doctor` doit être OK)

---

## Installation

```bash
# 1. Cloner le projet
git clone https://github.com/m-deye/heyen-mobile.git
cd heyen-mobile

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier qu’un appareil / émulateur est détecté
flutter devices

# 4. Lancer l’application
flutter run
```

### Ce que le visiteur verra

En debug, l’app essaie d’abord l’API locale (`http://127.0.0.1:3000`, ou `http://10.0.2.2:3000` sur émulateur Android).

- **Backend allumé** → mêmes produits / commandes que chez toi (données API).
- **Backend éteint** → l’app bascule sur des **données de démo** (catégories, produits, connexion test). L’interface reste la même.

Comptes de test (mode local / démo) :

| Type | Téléphone | Mot de passe |
|---|---|---|
| Particulier | `12345678` | `123456` |
| Commerçant | `87654321` | `123456` |

### Configurer l’URL de l’API backend

```bash
# Émulateur Android → API sur ta machine
flutter run --dart-define=HEYN_API_BASE_URL=http://10.0.2.2:3000

# iOS / Windows / Chrome → API locale
flutter run --dart-define=HEYN_API_BASE_URL=http://127.0.0.1:3000
```

Le backend est un projet séparé : [m-deye/heyen](https://github.com/m-deye/heyen). Sans lui, `flutter run` affiche quand même l’app avec les données de démo.

---

## Scripts utiles

```bash
# Analyse statique du code
dart analyze

# Tests unitaires et widget
flutter test

# Build APK release
flutter build apk --release

# Build iOS (macOS uniquement)
flutter build ios --release
```

---

## Captures d'écran

| Accueil | Catalogue | Détail produit | Panier |
|---|---|---|---|
| _À venir_ | _À venir_ | _À venir_ | _À venir_ |

| Commandes | Profil | Connexion | Checkout |
|---|---|---|---|
| _À venir_ | _À venir_ | _À venir_ | _À venir_ |

---

## Configuration du backend

Le backend est un projet Next.js séparé utilisant Prisma + PostgreSQL. Voir le [dépôt backend Heyen](https://github.com/m-deye/heyen).

```bash
# Dans le dossier backend
docker compose up -d        # Lancer PostgreSQL
npx prisma migrate deploy   # Appliquer les migrations
npm run prisma:seed          # Données de test
npm run dev                  # Serveur de dev (port 3000)
```

---

## Contributeurs

- **Mohamed Deye** — Développeur principal

---

## Licence

Projet propriétaire — tous droits réservés © 2026 Heyn.
