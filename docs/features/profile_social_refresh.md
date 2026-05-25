# Profile Social Refresh

## Resume
Le profil a ete retravaille pour ressembler davantage a une page de reseau social, avec un hero visuel, des statistiques de reseau et des actions d'engagement plus visibles. L'edition du compte se fait maintenant sur une page separee.

## Comportement attendu
- Le profil affiche un header avec avatar, nom, username, statut public/prive et compteurs sociaux.
- L'utilisateur peut rapidement rechercher des profils ou ouvrir l'ecran d'edition depuis le haut de page.
- Le profil n'affiche plus directement les listes d'amis et de demandes; il expose des cartes de navigation vers ces vues.
- L'edition du profil se fait sur une page dediee.

## Fichiers concernes
- `front/lib/screens/account/account_page.dart` - orchestration de la page profil
- `front/lib/screens/account/edit_profile_page.dart` - ecran dedie a l'edition du profil
- `front/lib/screens/account/widgets/social_profile_header.dart` - hero social du profil
- `front/lib/screens/account/widgets/profile_edit_card.dart` - carte d'edition du profil
- `front/lib/screens/account/widgets/profile_sections.dart` - cartes de navigation et composants de sections
- `front/test/screens/account/widgets/social_profile_header_test.dart` - couverture du header
- `front/test/screens/account/widgets/profile_navigation_card_test.dart` - couverture des cartes de navigation

## Dependances
- Flutter Material - composition UI
- Riverpod - etat asynchrone du profil, des amis et des demandes
- Supabase Auth - session et deconnexion

## Decisions techniques
- Les labels existants de localisation ont ete reutilises pour eviter un changement de catalogue texte plus large.
- Les sous-composants du profil ont ete extraits pour garder `account_page.dart` lisible et faciliter les tests widget.
- Les vues detaillees du reseau restent dans `FriendsPage`; le profil sert de hub et non de liste.
