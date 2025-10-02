# PaySats

## Description

**PaySats** est un super-wallet mobile révolutionnaire développé avec Flutter qui transforme les services financiers en Afrique de l'Ouest. Cette application combine Bitcoin, Mobile Money et épargne dans une seule interface simple et intuitive.

## Vision

Rendre les paiements et l'épargne accessibles à tous au Sénégal et en Afrique de l'Ouest, sans dépendre des banques traditionnelles.

**PaySats = Mobile Money + Bitcoin + Épargne**

## Fonctionnalités Principales

### 💸 Paiements et Transferts

- **Mobile Money intégré** : Connexion avec Wave, Orange Money, Free Money
- **Bitcoin Lightning** : Paiements rapides et peu coûteux via QR codes
- **Envoi/Réception** : Transferts d'argent instantanés entre utilisateurs
- **Conversion automatique** : Dépôt Mobile Money → Bitcoin (sats)
- **Retrait facile** : Bitcoin → Mobile Money en FCFA

### 🏦 Épargne Intelligente (Vaults)

- **Coffres personnalisés** : Création d'objectifs d'épargne (Tabaski, études, projets)
- **Verrouillage temporel** : Blocage des fonds pour 1, 3, 6, 12 mois
- **Épargne automatique** : Programmation de virements réguliers

### 🔒 Sécurité Avancée

- **Seed phrase** : Phrase mnémonique pour la récupération du portefeuille
- **PIN sécurisé** : Code d'accès personnel
- **Chiffrement end-to-end** : Protection des données sensibles
- **Backup multi-signatures** : Sécurité renforcée pour gros montants

### 🌍 Adapté au Contexte Local

- **Mode hors-ligne** : Fonctionnalités essentielles sans internet
- **Téléphones bas de gamme** : Optimisé pour tous les appareils
- **Interface culturelle** : Design adapté aux habitudes locales

## Captures d'écran

![Captures d'écran](assets/images/paysats-wallet.jpg)

## Technologies utilisées

- **Flutter/Dart** : Développement cross-platform (iOS, Android, Web)
- **Provider** : Gestion d'état réactive
- **Bitcoin Lightning Network** : Paiements rapides et peu coûteux
- **APIs Mobile Money** : Intégration Wave, Orange Money, Mixx by Yas
- **CoinGecko API** : Taux de change en temps réel
- **Chiffrement AES** : Sécurité des données utilisateur

## Structure du projet

```
lib/
├── main.dart                # Point d'entrée de l'application
├── screens/                 # Écrans de l'application
│   ├── home_screen.dart     # Écran d'accueil
│   ├── send_screen.dart     # Écran d'envoi de Bitcoin
│   ├── receive_screen.dart  # Écran de réception de Bitcoin
│   └── ...
├── services/                # Services métier
│   ├── wallet_service.dart  # Gestion du portefeuille
│   └── ...
├── utils/                   # Utilitaires
└── widgets/                 # Widgets réutilisables
```

## Installation

### Prérequis

- Flutter SDK (3.7.2 ou supérieur)
- Dart (3.0.0 ou supérieur)
- Android Studio / Xcode
- Compte développeur pour APIs Mobile Money

### Étapes d'installation

1. Clonez ce dépôt :

   ```bash
   git clone https://github.com/ibou-dia/PaySats.git
   ```

2. Accédez au répertoire du projet :

   ```bash
   cd PaySats
   ```

3. Installez les dépendances :

   ```bash
   flutter pub get
   ```

4. Configurez les clés API :

   ```bash
   # Créez un fichier .env avec vos clés API
   cp .env.example .env
   ```

5. Lancez l'application :
   ```bash
   flutter run
   ```

## Configuration

### Variables d'environnement

Créez un fichier `.env` à la racine du projet :

```env
# APIs Mobile Money
WAVE_API_KEY=votre_cle_wave
ORANGE_MONEY_API_KEY=votre_cle_orange
FREE_MONEY_API_KEY=votre_cle_free
MIXX_API_KEY=votre_cle_mixx

# Bitcoin Lightning
LIGHTNING_NODE_URL=votre_noeud_lightning
LIGHTNING_MACAROON=votre_macaroon

# APIs Financières
COINGECKO_API_KEY=votre_cle_coingecko
```

## Contribution

Les contributions sont les bienvenues ! Consultez notre [guide de contribution](CONTRIBUTING.md) pour plus d'informations.

## Contact

- **Email** : ibrahimadia800@gmail.com

---

**PaySats - L'avenir des services financiers en Afrique de l'Ouest** 🚀

## Licence

Ce projet est sous licence MIT.
