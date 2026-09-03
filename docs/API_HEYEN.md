# Documentation API — même contrat que Heyen

Ce fichier reprend la **référence des routes** du README backend Heyen
(`heyen-main/README.md`, section « Référence des routes API »).

Les tableaux **Méthode / Route / Description / Auth** sont les **mêmes**.
En dessous de chaque groupe : ce que l’app Flutter en fait.

Backend : Next.js. Réponses `{ "success": true, "data": ... }` ou
`{ "success": false, "message": "...", "details": ... }`.

Authentification mobile (identique Heyen) :

```
Authorization: Bearer <accessToken>
```

L’`accessToken` (courte durée) est renouvelé via `POST /api/auth/refresh`
avec le `refreshToken` (longue durée, stocké côté mobile).

Dans Flutter : interceptor dans `lib/core/api/api_client.dart`.
URL de base : `lib/core/api/api_config.dart`.

---

## Authentification — `/api/auth`

| Méthode | Route | Description | Auth |
| --- | --- | --- | --- |
| POST | `/api/auth/register` | Création de compte | — |
| POST | `/api/auth/login` | Connexion | — |
| POST | `/api/auth/refresh` | Renouvelle l'access token | — (refresh token dans le body) |
| POST | `/api/auth/logout` | Révoque le refresh token | — |
| POST | `/api/auth/forgot-password` | Envoie un lien de reset password | — |
| POST | `/api/auth/reset-password` | Réinitialise le mot de passe via le token reçu par email | — |

**Flutter :** register, login, refresh, logout, forgot-password, reset-password → `lib/features/auth/` (`auth_api.dart`, écrans `forgot_password_screen.dart` / `reset_password_screen.dart`).

---

## Utilisateur — `/api/users`

| Méthode | Route | Description | Auth |
| --- | --- | --- | --- |
| GET | `/api/users/me` | Profil courant | Utilisateur |
| PATCH | `/api/users/me` | Met à jour le profil | Utilisateur |
| GET | `/api/users/me/addresses` | Liste des adresses de livraison | Utilisateur |
| POST | `/api/users/me/addresses` | Ajoute une adresse | Utilisateur |
| PATCH | `/api/users/me/addresses/:id` | Modifie une adresse | Utilisateur (propriétaire) |
| DELETE | `/api/users/me/addresses/:id` | Supprime une adresse | Utilisateur (propriétaire) |

**Flutter :** GET me → `api_profile_repository.dart`. POST adresse → checkout (`addresses_api.dart`).  
PATCH me, GET/PATCH/DELETE adresses → **pas dans l’app**.

---

## Catalogue — `/api/categories`, `/api/products`

| Méthode | Route | Description | Auth |
| --- | --- | --- | --- |
| GET | `/api/categories` | Liste des catégories actives | — |
| POST | `/api/categories` | Crée une catégorie | Admin |
| GET | `/api/categories/:id` | Détail + produits de la catégorie | — |
| PATCH | `/api/categories/:id` | Modifie une catégorie | Admin |
| DELETE | `/api/categories/:id` | Désactive une catégorie | Admin |
| GET | `/api/products?categoryId=&search=&page=&pageSize=` | Liste paginée des produits | — |
| POST | `/api/products` | Crée un produit (rattaché à une catégorie) | Admin |
| GET | `/api/products/:id` | Détail d'un produit | — |
| PATCH | `/api/products/:id` | Modifie un produit | Admin |
| DELETE | `/api/products/:id` | Désactive un produit | Admin |

**Flutter :** GET categories, GET products, GET product/:id → `api_catalog_repository.dart`.  
Routes **Admin** et GET catégorie/:id → **pas dans l’app client**.

---

## Panier — `/api/cart`

| Méthode | Route | Description | Auth |
| --- | --- | --- | --- |
| GET | `/api/cart` | Panier courant (avec total) | Utilisateur |
| DELETE | `/api/cart` | Vide le panier | Utilisateur |
| POST | `/api/cart/items` | Ajoute un produit au panier | Utilisateur |
| PATCH | `/api/cart/items/:id` | Modifie la quantité d'un article | Utilisateur |
| DELETE | `/api/cart/items/:id` | Retire un article du panier | Utilisateur |

**Flutter :** tout le panier → `lib/features/cart/data/cart_api.dart`.

---

## Commandes — `/api/orders`

| Méthode | Route | Description | Auth |
| --- | --- | --- | --- |
| GET | `/api/orders?page=&pageSize=&all=true` | Historique des commandes (`all=true` réservé aux admins) | Utilisateur |
| POST | `/api/orders` | Crée une commande à partir du panier courant | Utilisateur |
| GET | `/api/orders/:id` | Détail d'une commande | Propriétaire ou Admin |
| PATCH | `/api/orders/:id` | Change le statut de la commande | Admin |

**Flutter :** GET liste + POST (checkout particulier) → `api_orders_repository.dart`.  
GET/:id et PATCH (admin) → **pas dans l’app**.  
Devis commerçant : **n’existe pas** dans Heyen.

---

## Santé (README Heyen)

`GET /api/health` — état de l’API et de PostgreSQL.

**Flutter :** non affiché dans l’UI.

---

## Ce que le README Heyen a en plus (pas recopié ici)

Installation Node, `.env`, Prisma, Docker, structure `src/`, notes Next.js 16,
seed admin `admin@heyen.app`. Ça reste **uniquement** dans le projet backend.

Lancer Heyen : voir `heyen-main/README.md` (Installation, Base de données, Lancer le serveur).
Lancer l’app : `ecommerce_app/README.md`.
