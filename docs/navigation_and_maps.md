# Navigation connectee et onglet Maps

## Objectif

Cette documentation explique :

- comment fonctionne la bottom navigation connectee
- comment l'onglet `Maps` est branche
- comment ajouter un nouvel onglet
- comment modifier un onglet existant

Le point d'entree principal de cette fonctionnalite est :

- [front/lib/screens/app/authenticated_app_shell.dart](/Users/samuelblard/Documents/projects/Travelmate/front/lib/screens/app/authenticated_app_shell.dart:1)

La page carte est ici :

- [front/lib/screens/maps/maps_screen.dart](/Users/samuelblard/Documents/projects/Travelmate/front/lib/screens/maps/maps_screen.dart:1)

## Comment la navigation fonctionne

L'application separe les routes publiques et l'espace connecte :

- les pages publiques comme l'accueil et le login vivent hors de la navbar
- l'espace connecte passe par `AuthenticatedAppShell`

`AuthenticatedAppShell` :

- affiche une `NavigationBar` en bas de l'ecran
- maintient l'onglet courant avec `_currentIndex`
- garde l'etat des pages avec `IndexedStack`
- n'instancie un onglet qu'au premier acces grace a `_visitedIndexes`

L'ordre des onglets est defini dans la liste `_tabs`.

Chaque onglet est decrit par `_AppTabItem` avec :

- `tab` : identifiant interne
- `label` : texte affiche dans la navbar
- `icon` : icone inactive
- `selectedIcon` : icone active
- `builder` : widget affiche pour cet onglet

## Onglets actuels

Les onglets actuellement configures sont :

1. `Home`
2. `Maps`
3. `Profil`

L'enum associe est :

```dart
enum AppShellTab { home, maps, profile }
```

## Comment fonctionne l'onglet Maps

L'onglet `Maps` affiche `MapsScreen`.

Le screen :

- utilise `mapbox_maps_flutter`
- lit le token via `MAPBOX_ACCESS_TOKEN`
- centre la carte sur La Reunion au chargement
- affiche un bouton pour recentrer la camera
- affiche un message de fallback si le token manque
- affiche un message de fallback si la plateforme ne supporte pas la vue native

Le token est initialise dans :

- [front/lib/utils/utils.dart](/Users/samuelblard/Documents/projects/Travelmate/front/lib/utils/utils.dart:1)

La logique actuelle est :

```dart
if (mapboxAccessToken.isNotEmpty) {
  MapboxOptions.setAccessToken(mapboxAccessToken);
}
```

## Variables d'environnement necessaires

Pour que l'onglet `Maps` fonctionne, il faut au minimum :

```env
MAPBOX_ACCESS_TOKEN=...
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

L'application lit ces valeurs via `--dart-define`.

Exemple de lancement :

```bash
RUBYOPT=-rlogger flutter run -d "iPhone 16 Pro Max" --dart-define-from-file=.env
```

Attention :

- le fichier `front/.env` doit contenir uniquement des lignes `CLE=valeur`
- toute ligne libre ou invalide casse `--dart-define-from-file`

## Ajouter un nouvel onglet

### 1. Creer l'ecran

Creer un nouvel ecran dans un dossier adapte, par exemple :

- `front/lib/screens/favorites/favorites_screen.dart`

### 2. Ajouter une valeur dans l'enum

Dans `authenticated_app_shell.dart`, ajouter la nouvelle valeur :

```dart
enum AppShellTab { home, maps, favorites, profile }
```

### 3. Ajouter l'onglet dans `_tabs`

Ajouter un nouvel `_AppTabItem` dans la liste `_tabs` :

```dart
_AppTabItem(
  tab: AppShellTab.favorites,
  label: 'Favoris',
  icon: Icons.favorite_border,
  selectedIcon: Icons.favorite,
  builder: (_) => const FavoritesScreen(),
),
```

### 4. Verifier l'ordre

L'ordre dans `_tabs` definit :

- l'ordre d'affichage dans la navbar
- l'index utilise par `IndexedStack`

## Modifier un onglet existant

### Changer le libelle ou l'icone

Modifier l'entree correspondante dans `_tabs`.

Exemple :

```dart
label: 'Carte',
icon: Icons.public_outlined,
selectedIcon: Icons.public,
```

### Remplacer l'ecran affiche

Changer uniquement le `builder`.

Exemple :

```dart
builder: (_) => const NewMapsScreen(),
```

### Changer l'onglet d'ouverture par defaut

Le shell accepte :

```dart
AuthenticatedAppShell(initialTab: AppShellTab.maps)
```

Le point de resolution principal se trouve dans :

- [front/lib/main.dart](/Users/samuelblard/Documents/projects/Travelmate/front/lib/main.dart:1)

## Modifier le comportement de Maps

Les changements les plus courants sont dans `MapsScreen`.

### Changer la position initiale

Modifier `_initialCamera` :

```dart
static final CameraOptions _initialCamera = CameraOptions(
  center: Point(coordinates: Position(longitude, latitude)),
  zoom: 10,
  pitch: 20,
);
```

### Changer le style de carte

Modifier `styleUri` dans `MapWidget`.

Exemple :

```dart
styleUri: MapboxStyles.SATELLITE_STREETS,
```

### Ajouter des boutons ou overlays

Ajouter les widgets dans le `Stack` au-dessus de `MapWidget`.

### Ajouter des interactions Mapbox

Utiliser `_mapboxMap` apres `onMapCreated`, par exemple pour :

- changer la camera
- ajouter des annotations
- charger un autre style
- ecouter les evenements de carte

## Fichiers a connaitre

- [front/lib/screens/app/authenticated_app_shell.dart](/Users/samuelblard/Documents/projects/Travelmate/front/lib/screens/app/authenticated_app_shell.dart:1)
- [front/lib/screens/maps/maps_screen.dart](/Users/samuelblard/Documents/projects/Travelmate/front/lib/screens/maps/maps_screen.dart:1)
- [front/lib/utils/utils.dart](/Users/samuelblard/Documents/projects/Travelmate/front/lib/utils/utils.dart:1)
- [front/lib/main.dart](/Users/samuelblard/Documents/projects/Travelmate/front/lib/main.dart:1)
- [front/test/widget_test.dart](/Users/samuelblard/Documents/projects/Travelmate/front/test/widget_test.dart:1)

## Verification recommandee apres modification

Apres modification d'un onglet ou de `MapsScreen` :

1. lancer `flutter test`
2. verifier le simulateur iOS ou un device Android
3. tester le changement d'onglet
4. verifier le hot reload si l'app tourne deja avec `flutter run`
