# Sélection de lieu sur la carte

## Résumé
L'onglet Maps permet maintenant de toucher un point d'intérêt Mapbox ou un libellé de lieu pour afficher les informations disponibles dans un panneau en bas d'écran.

## Comportement attendu
- Un tap sur un point d'intérêt affiche son nom, son type de source et toutes les métadonnées disponibles remontées par Mapbox.
- Un tap sur un libellé de lieu affiche son nom, sa catégorie et ses coordonnées.
- Un tap sur une zone vide de la carte ferme la sélection courante.
- Le bouton de fermeture du panneau efface aussi la sélection.
- Si aucun lieu n'est sélectionné, un état d'aide invite l'utilisateur à toucher la carte.
- Si certaines métadonnées sont absentes, seules les informations disponibles sont affichées.

## Fichiers concernés
- `front/lib/screens/maps/maps_screen.dart` — branche les interactions Mapbox et pilote la sélection active.
- `front/lib/screens/maps/models/selected_map_place.dart` — normalise les données d'un lieu sélectionné.
- `front/lib/screens/maps/widgets/map_place_details_sheet.dart` — affiche le panneau de détail.
- `front/lib/l10n/app_fr.arb` — libellés FR du panneau.
- `front/lib/l10n/app_en.arb` — libellés EN du panneau.
- `front/test/screens/maps/map_place_details_sheet_test.dart` — couvre l'état vide, l'état rempli et la fermeture.

## Dépendances
- `mapbox_maps_flutter` — fournit les interactions `TapInteraction` sur les POI et les labels de lieu du style standard.

## Décisions techniques
- Les données du lieu sont converties dans un modèle local unique pour éviter de propager les types Mapbox dans le widget d'affichage.
- La sélection s'appuie sur les featuresets standard de Mapbox (`StandardPOIs`, `StandardPlaceLabels`) afin de récupérer les métadonnées natives sans source personnalisée.
- Le panneau n'affiche que les champs réellement disponibles pour éviter les lignes vides ou trompeuses.
- Les coordonnées de POI ne passent pas par `feature.coordinate` car la version actuelle du SDK Flutter Mapbox peut renvoyer une géométrie brute incompatible avec ce getter. La résolution se fait via la position du tap, avec fallback sur le décodage manuel de la géométrie.
