# Guide de contribution à PaySats

Merci de votre intérêt pour contribuer à PaySats ! Ce document fournit les lignes directrices pour contribuer au projet.

## Comment contribuer

### Signaler des bugs

Si vous trouvez un bug :

1. Vérifiez d'abord que le bug n'a pas déjà été signalé dans les [issues](https://github.com/ibou-dia/PaySats/issues)
2. Créez une nouvelle issue avec un titre clair et une description détaillée
3. Incluez les étapes pour reproduire le bug
4. Ajoutez des captures d'écran si possible
5. Précisez votre environnement (version de l'application, appareil, OS)

### Proposer des améliorations

Pour proposer une nouvelle fonctionnalité :

1. Créez une issue décrivant la fonctionnalité souhaitée
2. Expliquez pourquoi cette fonctionnalité serait utile
3. Discutez de l'implémentation possible

### Soumettre du code

1. Forkez le dépôt
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/amazing-feature`)
3. Committez vos changements (`git commit -m 'Add some amazing feature'`)
4. Poussez vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une Pull Request

## Standards de code

### Style de code

- Suivez les [conventions de style Dart](https://dart.dev/guides/language/effective-dart/style)
- Utilisez [flutter_lints](https://pub.dev/packages/flutter_lints) pour la vérification du code
- Exécutez `flutter analyze` avant de soumettre du code

### Tests

- Ajoutez des tests unitaires pour les nouvelles fonctionnalités
- Assurez-vous que tous les tests passent avant de soumettre une PR
- Visez une couverture de test d'au moins 80%

### Documentation

- Documentez toutes les classes et méthodes publiques
- Mettez à jour la documentation existante si nécessaire
- Utilisez des commentaires clairs et concis

## Processus de revue

1. Au moins un mainteneur doit approuver votre PR
2. Les tests automatisés doivent passer
3. Votre code doit respecter les standards du projet
4. Les modifications importantes peuvent nécessiter plusieurs revues

## Environnement de développement

### Configuration

1. Installez Flutter (version 3.7.2 ou supérieure)
2. Configurez votre IDE (VS Code ou Android Studio recommandés)
3. Installez les extensions Flutter et Dart pour votre IDE
4. Configurez les variables d'environnement nécessaires

### Exécution locale

```bash
# Cloner le dépôt
git clone https://github.com/ibou-dia/PaySats.git

# Installer les dépendances
flutter pub get

# Exécuter l'application
flutter run
```

## Communication

- Utilisez les issues GitHub pour les discussions techniques
- Pour les questions sensibles, contactez-nous à ibrahimadia800@gmail.com

## Code de conduite

### Nos engagements

- Respecter tous les contributeurs, quelle que soit leur expérience
- Accepter les critiques constructives
- Se concentrer sur ce qui est le mieux pour la communauté
- Faire preuve d'empathie envers les autres membres

### Comportements inacceptables

- Utilisation de langage ou d'images à caractère sexuel
- Trolling, commentaires insultants/désobligeants, attaques personnelles
- Harcèlement public ou privé
- Publication d'informations privées sans autorisation

## Licence

En contribuant à PaySats, vous acceptez que vos contributions soient sous licence MIT.

---

Merci de contribuer à rendre PaySats meilleur pour tous ! 🚀
