# Supabase RLS pour Travelmate

## Résumé
Le projet utilise des politiques RLS pour sécuriser les données Supabase tout en gardant les écrans existants fonctionnels.

## Comportement attendu
- Les utilisateurs authentifiés peuvent lire la liste des profils, nécessaire pour créer une sortie planifiée.
- Un utilisateur peut créer et mettre à jour son propre profil.
- Les utilisateurs authentifiés peuvent lire et créer des sorties planifiées.
- L’écran d’accueil lit les sorties planifiées depuis `planned_outings`.
- L’interface n’affiche que les sorties où l’utilisateur connecté figure dans la liste des participants.
- Les tables concernées ont RLS activé.

## Fichiers concernés
- `supabase/migrations/20260507_add_rls_policies.sql` — activation de RLS et politiques SQL.
- `front/lib/services/user_service.dart` — lecture de la liste des profils.
- `front/lib/services/planned_outing_service.dart` — lecture et création des sorties planifiées.

## Dépendances
- Supabase Auth pour identifier l’utilisateur courant avec `auth.uid()`.
- Supabase Postgres RLS pour filtrer l’accès aux tables.

## Décisions techniques
- Les profils sont lisibles par tous les utilisateurs authentifiés afin de permettre la sélection de participants dans l’éditeur de sorties.
- Les sorties planifiées sont traitées comme une ressource partagée en lecture, mais seules les créations sont autorisées pour l’instant.
- Si un contrôle par propriétaire ou des modifications/suppressions deviennent nécessaires plus tard, il faudra ajouter une colonne `owner_id` et durcir les politiques en conséquence.
