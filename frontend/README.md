# FlightHub Frontend

Une interface moderne et responsive pour la recherche de vols, construite avec React.js et Vite.

## 🚀 Technologies Utilisées

- **React 18** - Framework JavaScript pour l'interface utilisateur
- **Vite** - Outil de build rapide et moderne
- **TypeScript** - Typage statique pour JavaScript
- **Tailwind CSS** - Framework CSS utilitaire
- **Lucide React** - Icônes modernes et légères
- **PostCSS** - Outil de transformation CSS

## 📁 Structure du Projet

```
frontend/
├── src/
│   ├── components/          # Composants React réutilisables
│   │   ├── HeroSection.tsx      # Section héro avec titre principal
│   │   ├── FlightSearchForm.tsx # Formulaire de recherche de vols
│   │   └── FeaturesSection.tsx  # Section des fonctionnalités
│   ├── App.tsx             # Composant principal de l'application
│   ├── App.css             # Styles CSS personnalisés
│   ├── index.css           # Styles globaux et directives Tailwind
│   └── main.tsx            # Point d'entrée de l'application
├── public/                 # Assets statiques
├── tailwind.config.js      # Configuration Tailwind CSS
├── postcss.config.js       # Configuration PostCSS
├── package.json            # Dépendances et scripts
└── README.md               # Documentation du projet
```

## 🎯 Fonctionnalités

### Interface de Recherche
- **Types de voyage** : Aller simple, Aller-retour
- **Champs de saisie** : Aéroport de départ, destination, dates
- **Validation** : Champs requis et validation des dates
- **Bouton d'échange** : Permet d'inverser les aéroports
- **Design responsive** : S'adapte à tous les écrans

### Composants Modulaires
- **HeroSection** : Titre principal et sous-titre avec arrière-plan stylisé
- **FlightSearchForm** : Formulaire de recherche avec gestion d'état
- **FeaturesSection** : Présentation des fonctionnalités clés

### Design et UX
- **Interface moderne** : Design épuré avec gradients et ombres
- **Animations** : Transitions fluides et micro-interactions
- **Responsive** : Optimisé pour mobile, tablette et desktop
- **Accessibilité** : Labels appropriés et navigation au clavier

## 🛠️ Installation et Démarrage

### Prérequis
- Node.js (version 18 ou supérieure)
- npm ou yarn

### Installation
```bash
# Cloner le projet
git clone <repository-url>
cd flightHub/frontend

# Installer les dépendances
npm install

# Démarrer le serveur de développement
npm run dev
```

### Scripts Disponibles
```bash
npm run dev          # Démarre le serveur de développement
npm run build        # Construit l'application pour la production
npm run preview      # Prévisualise la version de production
npm run lint         # Vérifie le code avec ESLint
```

## 🔧 Configuration

### Tailwind CSS
Le projet utilise Tailwind CSS avec une configuration personnalisée :
- Couleurs personnalisées (primary, sky)
- Animations personnalisées (fade-in, slide-in)
- Ombres personnalisées (soft, medium, large)

### PostCSS
Configuration pour Tailwind CSS et Autoprefixer.

## 📱 Responsive Design

L'interface s'adapte automatiquement à différentes tailles d'écran :
- **Mobile** : Layout en colonne unique, typographie adaptée
- **Tablette** : Grille adaptative, espacement optimisé
- **Desktop** : Layout en colonnes multiples, navigation complète

## 🎨 Personnalisation

### Couleurs
Les couleurs principales peuvent être modifiées dans `tailwind.config.js` :
```javascript
colors: {
  primary: {
    500: '#3b82f6', // Couleur principale
    600: '#2563eb', // Couleur au survol
  }
}
```

### Composants
Chaque composant est modulaire et peut être facilement personnalisé :
- Modifier les props dans les composants
- Ajuster les styles dans les fichiers CSS
- Ajouter de nouvelles fonctionnalités

## 🔌 Intégration Backend

Le frontend est conçu pour s'intégrer avec une API Laravel :
- **Endpoints** : `/api/flights/search`, `/api/airlines`, `/api/airports`
- **Format** : JSON pour les requêtes et réponses
- **Authentification** : Prêt pour l'ajout de tokens JWT

## 🧪 Tests

```bash
# Exécuter les tests
npm run test

# Tests en mode watch
npm run test:watch

# Couverture de code
npm run test:coverage
```

## 📦 Build et Déploiement

### Build de Production
```bash
npm run build
```

### Déploiement
L'application peut être déployée sur :
- **Vercel** : Déploiement automatique depuis Git
- **Netlify** : Déploiement avec drag & drop
- **AWS S3** : Hébergement statique
- **Nginx** : Serveur web traditionnel

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement
- Consulter la documentation technique

---

**FlightHub** - Trouvez votre vol parfait ✈️
