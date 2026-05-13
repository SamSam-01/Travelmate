# Sorties planifiées

## Résumé
La fonctionnalité permet de créer et consulter des sorties planifiées depuis Supabase avec :

- un titre
- une visibilité (privée ou publique)
- une date/heure prévue
- une liste d’utilisateurs participants
- une liste d’activités

## Comportement attendu
- L’écran `Sorties` charge les sorties planifiées depuis la table Supabase `planned_outings`.
- La liste des utilisateurs est chargée depuis la table `profiles`.
- L’utilisateur peut créer une sortie via 3 étapes: détails, date/heure, activités.
- Chaque étape s’ouvre dans une page dédiée, puis revient à l’écran principal de création après confirmation.
- Les sorties créées sont enregistrées dans Supabase et réaffichées après création.
- L’écran d’accueil affiche aussi les sorties planifiées dans un carousel basé sur la table `planned_outings`.
- L’accueil et l’écran `Sorties` n’affichent que les sorties où l’utilisateur connecté est présent dans la liste des participants.
- Si aucune sortie planifiée n’existe encore, l’accueil peut afficher en secours les activités de `activities` marquées `tone = planned`.

## Fichiers concernés
- `front/lib/models/planned_outing_model.dart` — modèle métier et parsing Supabase.
- `front/lib/services/user_service.dart` — récupération des profils utilisateurs.
- `front/lib/services/planned_outing_service.dart` — lecture et création des sorties planifiées.
- `front/lib/screens/outings/outings_screen.dart` — écran de consultation et création.
- `front/lib/screens/home/home_screen.dart` — carousel de sorties planifiées.
- `front/lib/utils/planned_outings_helper.dart` — sélection des cartes affichées sur l’accueil.

## Dépendances
- `supabase_flutter` pour les accès aux données.
- `profiles` pour la source des utilisateurs.
- `planned_outings` pour la source des sorties planifiées.
- `activities` pour le carousel de sorties planifiées dans l’écran d’accueil.
- Les sorties planifiées visibles sont filtrées côté application par l’identifiant de l’utilisateur connecté.

## Décisions techniques
- Les participants et activités sont stockés sous forme de données JSON pour garder une structure souple.
- Le carousel de l’accueil réutilise le même modèle que l’écran de sorties pour éviter les divergences d’affichage.
- Le formulaire de création est découpé en 3 pages courtes pour limiter la charge cognitive, tout en gardant un écran principal récapitulatif vertical.
- L’accueil préfère `planned_outings` pour refléter les vraies sorties, avec un fallback sur `activities` quand aucun planning n’existe encore.
