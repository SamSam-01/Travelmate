# Profil Utilisateur

## Résumé
Affichage du profil public d'un utilisateur (ami) depuis la liste d'amis.

## Comportement attendu
- Depuis l'onglet "Amis", un clic sur le nom d'un ami ouvre une nouvelle page de profil.
- Affiche l'avatar de l'utilisateur (ou une icône par défaut).
- Affiche le nom d'utilisateur (username) et le nom d'affichage (displayName) si disponible.

## Fichiers concernés
- `lib/presentation/pages/user_profile_page.dart` — Page affichant les informations du profil.
- `lib/presentation/pages/friends_page.dart` — Modification pour ajouter la navigation (onTap) vers la page de profil.
- `test/presentation/pages/user_profile_page_test.dart` — Tests vérifiant l'affichage correct des informations utilisateur (avec et sans displayName).

## Dépendances
Aucune dépendance externe nouvelle ajoutée.

## Décisions techniques
- Passage de l'entité `UserProfile` directement depuis la page précédente plutôt que de faire une nouvelle requête réseau pour récupérer les informations. Cela simplifie la navigation et rend l'affichage instantané.
