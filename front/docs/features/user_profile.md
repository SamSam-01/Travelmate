# Profil Utilisateur

## Résumé
Affichage du profil public d'un utilisateur (ami) depuis la liste d'amis.

## Comportement attendu
- Depuis l'onglet "Amis", un clic sur le nom d'un ami ouvre une nouvelle page de profil.
- Affiche l'avatar de l'utilisateur (ou une icône par défaut).
- Affiche le nom d'utilisateur (username) et le nom d'affichage (displayName) si disponible.
- Affiche la liste des activités/sorties planifiées en commun avec cette personne.

## Fichiers concernés
- `lib/presentation/pages/user_profile_page.dart` — Page affichant les informations du profil et la liste des sorties en commun.
- `lib/presentation/widgets/planned_outing_card.dart` — Composant d'affichage d'une sortie (extrait pour réutilisation).
- `lib/presentation/providers/outing_providers.dart` — Fournit la liste des sorties partagées (`sharedOutingsProvider`).
- `lib/presentation/pages/friends_page.dart` — Modification pour ajouter la navigation (onTap) vers la page de profil.
- `lib/screens/outings/outings_screen.dart` — Mise à jour pour utiliser le nouveau widget partagé `PlannedOutingCard`.
- `test/presentation/pages/user_profile_page_test.dart` — Tests vérifiant l'affichage correct des informations utilisateur et de la liste des sorties.

## Dépendances
Aucune dépendance externe nouvelle ajoutée.

## Décisions techniques
- Passage de l'entité `UserProfile` directement depuis la page précédente plutôt que de faire une nouvelle requête réseau pour récupérer les informations. Cela simplifie la navigation et rend l'affichage instantané.
