# Friend System

## Résumé
Cette fonctionnalité ajoute un système d'amis complet adossé à Supabase.
Elle permet de rechercher un utilisateur par son username, d'envoyer une demande d'ami, de traiter les demandes reçues, de consulter les profils d'amis depuis la liste sociale et de limiter l'accès aux profils complets aux seules relations acceptées.

## Comportement attendu
- Un utilisateur authentifié peut rechercher d'autres utilisateurs via `username` et voir leur `display_name` public.
- Un utilisateur peut envoyer une demande d'ami si aucune relation active n'existe déjà.
- Un destinataire peut accepter ou refuser une demande reçue tant qu'elle est en attente.
- La liste des amis affiche uniquement les relations acceptées.
- La page `Amis` expose des cartes sociales et permet d'ouvrir le profil d'un ami ou d'un demandeur.
- Les profils complets dans `public.profiles` ne sont lisibles que par le propriétaire ou par un ami accepté.
- Les comptes existants sont backfillés avec un username provisoire unique si nécessaire.
- Les nouveaux comptes créent automatiquement leur profil public via un trigger `auth.users`.
- Les erreurs Supabase sont converties en erreurs applicatives et affichées dans l'UI.

## Fichiers concernés
- `supabase/migrations/20260507233000_friend_system.sql` — création et évolution du schéma, triggers, vue de recherche et policies RLS.
- `front/lib/domain/` — entités, repository et use cases du système d'amis.
- `front/lib/data/` — modèles, datasource Supabase et implémentation du repository.
- `front/lib/presentation/providers/friendship_providers.dart` — injection Riverpod, état async et actions.
- `front/lib/presentation/pages/` et `front/lib/presentation/widgets/` — pages et composants UI de la feature.
- `front/lib/screens/account/account_page.dart` — migration de l'écran profil vers le nouveau schéma `profiles`.
- `front/lib/presentation/pages/friend_profile_page.dart` — consultation du profil d'un ami.
- `front/lib/screens/login/login_page.dart` — ajout du username à l'inscription.
- `front/test/` — couverture use cases, repository, providers et widgets de la feature.

## Dépendances
- `flutter_riverpod` — injection, providers et notifiers de la feature.
- `fpdart` — retour `Either<Failure, T>` pour la couche domaine/data.
- `flutter_localizations` et `intl` — système i18n et génération des localizations.
- `mocktail` — mocks pour les tests unitaires, providers et widgets.
- `supabase_flutter` — client Supabase utilisé par le datasource distant.

## Décisions techniques
- La recherche publique passe par une vue `profile_search` dédiée pour ne jamais exposer le profil complet dans les résultats de recherche.
- Les policies RLS de `profiles` protègent la lecture complète au niveau base, indépendamment du client Flutter.
- Le système est introduit dans une architecture `core/data/domain/presentation` limitée à cette feature pour éviter un refactor global du projet.
- L'écran compte est migré vers le nouveau schéma de profil au lieu de conserver `website`, afin de ne garder qu'un seul modèle source de vérité.
- La page `Amis` sert de hub social et route vers un écran de profil ami plutôt que d'afficher seulement des `ListTile`.
- L'i18n est mise en place au niveau application avec des fichiers ARB en français et en anglais, la locale par défaut restant française.
