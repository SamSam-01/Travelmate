# Ajout de lieu à une sortie

## Résumé
Permet d'ajouter un lieu sélectionné depuis la carte à une sortie existante, ou de créer une nouvelle sortie pré-remplie avec ce lieu.

## Comportement attendu
- Un bouton "Ajouter à une sortie" est présent dans le panneau de détails du lieu sur la carte (`MapPlaceDetailsSheet`).
- Au clic, une boîte de dialogue affiche la liste des sorties planifiées de l'utilisateur.
- L'utilisateur peut sélectionner une sortie existante, choisir une heure, et le lieu est ajouté en tant qu'activité.
- L'utilisateur peut aussi choisir de créer une nouvelle sortie : le formulaire de sortie s'ouvre, pré-rempli avec le lieu sélectionné.

## Fichiers concernés
- `lib/screens/maps/widgets/map_place_details_sheet.dart` — Ajout du bouton d'action.
- `lib/screens/maps/widgets/add_place_to_outing_dialog.dart` — Dialogue principal de sélection/création.
- `lib/services/planned_outing_service.dart` — Support de l'insertion de nouvelles `activities` à la volée.
- `lib/screens/outings/outings_screen.dart` — Refactoring de `PlannedOutingFormSheet` pour permettre le pré-remplissage.
- `lib/models/activity_model.dart` — Ajout de la méthode `toInsertJson()`.
- `test/models/activity_model_test.dart` — Tests de la logique de transformation JSON.
- `test/models/planned_outing_model_test.dart` — Tests du getter `asActivity`.
- `supabase/migrations/20260611220000_allow_activity_insert.sql` — Migration de base de données.

## Dépendances
- Base de données Supabase (Table `activities` mise à jour avec RLS).

## Décisions techniques
- **Création dynamique d'activités** : Au lieu de requérir une liste statique d'activités en base, une policy `INSERT` a été ajoutée pour permettre aux utilisateurs de créer des activités à la volée (à partir des détails d'un lieu de la carte).
- **Transformation de modèle** : Le modèle `Activity` a été enrichi d'un `toInsertJson()` et `PlannedOutingActivity` d'un getter `asActivity` pour faciliter l'insertion en base de données.
