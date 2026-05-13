# Sélection de lieu sur la carte

## Résumé
L'onglet Maps permet maintenant de toucher un point d'intérêt Mapbox ou un libellé de lieu pour afficher une fiche compacte ancrée en bas d'écran. Si `GOOGLE_PLACES_API_KEY` est défini, il ajoute aussi une recherche Google Places ciblée, puis un écran plein écran plus détaillé accessible par swipe vers le haut.

## Comportement attendu
- Un tap sur un point d'intérêt affiche une fiche compacte collée au bas de l'écran.
- Un tap sur un libellé de lieu affiche la même fiche compacte avec les informations disponibles.
- Une recherche Google Places ne se déclenche qu'après 2 caractères et un debounce pour limiter le nombre d'appels facturables.
- La sélection d'un résultat Google recentre la carte et affiche une fiche compacte avec photo principale, note, statut ouvert/fermé, catégorie et adresse.
- Quand un lieu est sélectionné, la barre de recherche disparaît pour laisser la place à la fiche détaillée.
- Un swipe vers le haut sur la fiche compacte, ou un tap sur l'action dédiée, ouvre un écran plein écran avec plus de détails sur l'établissement.
- Depuis cet écran plein écran, un swipe vers le bas quand la vue est déjà en haut referme l'écran et ramène à la carte.
- Un tap sur une zone vide de la carte ferme la sélection courante.
- Le bouton de fermeture du panneau efface aussi la sélection.
- Si aucun lieu n'est sélectionné, aucun panneau de détail n'est affiché.
- Si certaines métadonnées sont absentes, seules les informations disponibles sont affichées.
- Si `GOOGLE_PLACES_API_KEY` est absent, la carte reste utilisable mais la recherche Google est désactivée.

## Fichiers concernés
- `front/lib/screens/maps/maps_screen.dart` — branche les interactions Mapbox et pilote la sélection active.
- `front/lib/screens/maps/map_place_details_page.dart` — affiche l'écran plein écran avec les détails enrichis du lieu.
- `front/lib/screens/maps/widgets/map_place_search_panel.dart` — affiche la recherche Google Places et la liste de suggestions.
- `front/lib/screens/maps/models/selected_map_place.dart` — normalise les données d'un lieu sélectionné.
- `front/lib/screens/maps/widgets/map_place_detail_components.dart` — factorise les briques visuelles de la fiche compacte et de l'écran détaillé.
- `front/lib/screens/maps/widgets/map_place_details_sheet.dart` — affiche la fiche compacte en bas de carte.
- `front/lib/data/datasources/google_places_remote_data_source.dart` — interroge l'API Google Places REST avec un field mask contrôlé.
- `front/lib/data/repositories/place_search_repository_impl.dart` — traduit les erreurs Google Places en `Failure`.
- `front/lib/domain/usecases/search_place_suggestions_use_case.dart` — encapsule l'autocomplete.
- `front/lib/domain/usecases/get_place_details_use_case.dart` — encapsule la récupération des détails Essentials.
- `front/lib/l10n/app_fr.arb` — libellés FR du panneau.
- `front/lib/l10n/app_en.arb` — libellés EN du panneau.
- `front/test/screens/maps/map_place_details_sheet_test.dart` — couvre l'état vide, le résumé compact, la fermeture et l'ouverture des détails.
- `front/test/screens/maps/map_place_search_panel_test.dart` — couvre l'affichage des suggestions.
- `front/test/data/datasources/google_places_remote_data_source_test.dart` — vérifie le field mask et le parsing des nouveaux détails.
- `front/test/data/models/place_search_suggestion_model_test.dart` — vérifie le parsing autocomplete.
- `front/test/domain/usecases/place_search_use_cases_test.dart` — couvre les deux use cases.

## Dépendances
- `mapbox_maps_flutter` — fournit les interactions `TapInteraction` sur les POI et les labels de lieu du style standard.
- `Google Places API (REST)` — fournit l'autocomplete et les détails enrichis du lieu.

## Décisions techniques
- Les données du lieu sont converties dans un modèle local unique pour éviter de propager les types Mapbox dans le widget d'affichage.
- La sélection s'appuie sur les featuresets standard de Mapbox (`StandardPOIs`, `StandardPlaceLabels`) afin de récupérer les métadonnées natives sans source personnalisée.
- La carte reste prioritaire dans l'écran principal. La fiche par défaut est volontairement compacte pour ne pas masquer le contexte géographique.
- Les détails longs sont déplacés dans un écran dédié pour rendre la lecture plus agréable sans sacrifier l'exploration de la carte.
- Le panneau n'affiche que les champs réellement disponibles pour éviter les lignes vides ou trompeuses.
- Les coordonnées de POI ne passent pas par `feature.coordinate` car la version actuelle du SDK Flutter Mapbox peut renvoyer une géométrie brute incompatible avec ce getter. La résolution se fait via la position du tap, avec fallback sur le décodage manuel de la géométrie.
- L'intégration Google n'utilise pas le SDK natif. Le nom affiché provient de l'autocomplete, puis les détails de lieu sont chargés via un field mask explicite.
- Les champs `rating`, `userRatingCount` et `regularOpeningHours` augmentent le niveau de facturation Place Details par rapport à la version strictement Essentials. Ils sont demandés ici parce qu'ils apportent une valeur directe dans la fiche de lieu.
