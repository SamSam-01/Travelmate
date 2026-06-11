# Sélection de lieu sur la carte

## Résumé
L'onglet Maps permet maintenant de toucher un point d'intérêt Mapbox ou un libellé de lieu pour afficher une fiche compacte ancrée en bas d'écran. Si `GOOGLE_PLACES_API_KEY` est défini, il ajoute aussi une recherche Google Places ciblée. La fiche s'agrandit ensuite par swipe vertical animé, sans quitter l'écran de carte.

## Comportement attendu
- Un tap sur un point d'intérêt affiche une fiche compacte collée au bas de l'écran.
- Un tap sur un libellé de lieu affiche la même fiche compacte avec les informations disponibles.
- Une recherche Google Places ne se déclenche qu'après 2 caractères et un debounce pour limiter le nombre d'appels facturables.
- La sélection d'un résultat Google recentre la carte et affiche une fiche compacte avec photo principale, note, statut ouvert/fermé, catégorie et adresse.
- Les suggestions Google restent affichées comme des éléments de liste interactifs et tactiles au sein du panneau de recherche.
- La barre de recherche reste affichée au-dessus de la carte tant que la fiche n'est pas largement ouverte.
- Quand la fiche monte, la barre de recherche se décale et s'efface progressivement pour suivre visuellement l'expansion du sheet.
- L'aperçu compact s'arrête à l'adresse du lieu. Les détails longs n'apparaissent qu'après expansion.
- L'image principale occupe toute la largeur visible du sheet dès l'aperçu.
- Un swipe vers le bas sur la fiche agrandie la réduit à nouveau, sans effet de changement de page.
- Un tap sur une zone vide de la carte ferme la sélection courante.
- Le bouton de fermeture du panneau efface aussi la sélection.
- Si aucun lieu n'est sélectionné, aucun panneau de détail n'est affiché.
- Si certaines métadonnées sont absentes, seules les informations disponibles sont affichées.
- Si `GOOGLE_PLACES_API_KEY` est absent, la carte reste utilisable mais la recherche Google est désactivée.

## Fichiers concernés
- `front/lib/screens/maps/maps_screen.dart` — branche les interactions Mapbox et pilote la sélection active.
- `front/lib/screens/maps/widgets/map_place_search_panel.dart` — affiche la recherche Google Places et la liste de suggestions.
- `front/lib/screens/maps/models/selected_map_place.dart` — normalise les données d'un lieu sélectionné.
- `front/lib/screens/maps/widgets/map_place_detail_components.dart` — factorise les briques visuelles de la fiche compacte et de l'écran détaillé.
- `front/lib/screens/maps/widgets/map_place_details_sheet.dart` — affiche la fiche compacte puis extensible en bas de carte.
- `front/lib/data/datasources/google_places_remote_data_source.dart` — interroge l'API Google Places REST avec un field mask contrôlé.
- `front/lib/data/repositories/place_search_repository_impl.dart` — traduit les erreurs Google Places en `Failure`.
- `front/lib/domain/usecases/search_place_suggestions_use_case.dart` — encapsule l'autocomplete.
- `front/lib/domain/usecases/get_place_details_use_case.dart` — encapsule la récupération des détails Essentials.
- `front/lib/l10n/app_fr.arb` — libellés FR du panneau.
- `front/lib/l10n/app_en.arb` — libellés EN du panneau.
- `front/test/screens/maps/map_place_details_sheet_test.dart` — couvre l'état vide, le résumé compact, la fermeture et l'expansion des détails.
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
- L'agrandissement passe par `DraggableScrollableSheet` pour donner une sensation de continuité visuelle entre l'aperçu et le détail complet.
- Le panneau n'affiche que les champs réellement disponibles pour éviter les lignes vides ou trompeuses.
- Les coordonnées de POI ne passent pas par `feature.coordinate` car la version actuelle du SDK Flutter Mapbox peut renvoyer une géométrie brute incompatible avec ce getter. La résolution se fait via la position du tap, avec fallback sur le décodage manuel de la géométrie.
- L'intégration Google n'utilise pas le SDK natif. Le nom affiché provient de l'autocomplete, puis les détails de lieu sont chargés via un field mask explicite.
- Les champs `rating`, `userRatingCount` et `regularOpeningHours` augmentent le niveau de facturation Place Details par rapport à la version strictement Essentials. Ils sont demandés ici parce qu'ils apportent une valeur directe dans la fiche de lieu.
