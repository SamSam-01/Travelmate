# Invitations aux sorties (Validation)

## Résumé
Le système de validation des sorties permet d'ajouter des personnes à une activité planifiée en leur envoyant une invitation, au lieu de les inscrire d'office. L'invité peut alors accepter ou refuser l'invitation depuis sa page d'accueil.

## Comportement attendu
- **Création** : Lors de la création d'une sortie, le créateur est automatiquement ajouté avec le statut `accepted`. Les autres participants invités reçoivent le statut `pending`.
- **Affichage (Accueil)** : Les invitations en attente (`pending`) s'affichent tout en haut de la page d'accueil sous forme de cartes d'invitation avec les boutons "Accepter" et "Refuser".
- **Validation** : 
  - Si l'utilisateur clique sur "Accepter", son statut passe à `accepted` et la sortie apparaît dans son carrousel des "Sorties planifiées".
  - Si l'utilisateur clique sur "Refuser", son statut passe à `declined`. La sortie disparaît de son écran.

## Fichiers concernés
- `supabase/migrations/20260611213600_add_participant_status.sql` — Ajout de la colonne `status` dans la table `planned_outing_participants` et de la politique RLS correspondante.
- `lib/models/planned_outing_model.dart` — Intégration du champ `status` dans le modèle `PlannedOutingUser` et ajout des méthodes de vérification (`isUserPending`, `isUserAccepted`).
- `lib/services/planned_outing_service.dart` — Récupération du statut, gestion du statut par défaut lors de la création, et mise à jour du statut.
- `lib/screens/home/home_screen.dart` — UI affichant les invitations en attente et déclenchant la mise à jour.
- `test/models/planned_outing_model_test.dart` — Tests unitaires du parsing de statut.

## Dépendances
Aucune nouvelle dépendance externe n'est utilisée.

## Décisions techniques
- **Conservation du statut "declined"** : Nous avons choisi de conserver la ligne en base de données avec le statut `declined` au lieu de la supprimer, ce qui permet de garder une trace historique des invitations refusées (et éventuellement d'empêcher le spam).
- **Gestion des états UI** : Le rafraîchissement des invitations depuis la page d'accueil recharge la requête globale `_loadData()` pour mettre à jour à la fois le panneau des invitations en attente et le carrousel des sorties planifiées de manière synchronisée.
