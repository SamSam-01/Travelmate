# Instructions de contribution

## Flutter

- Garder les pages lisibles : extraire des widgets privés quand un `build` devient long ou mélange trop de responsabilités.
- Placer les couleurs, typographies et styles partagés dans le thème plutôt que dans chaque écran.
- Lancer `dart format lib test`, `flutter analyze` et `flutter test` avant de pousser.
- Eviter de bundler des secrets ou fichiers `.env` dans les assets Flutter.
- Passer la configuration sensible via `--dart-define`, par exemple `SUPABASE_URL` et `SUPABASE_ANON_KEY`.
- Proteger les flows authentifiés : une page compte doit rediriger si aucune session n'est disponible.
- Pour les changements natifs, assets ou `pubspec.yaml`, relancer l'application au lieu de compter sur le hot reload.

## Git et commits

- Travailler sur une branche courte et nommee selon l'intention, par exemple `create_login_page`.
- Faire des commits atomiques avec un message clair au format imperatif.
- Verifier le diff avant commit avec `git status` et `git diff --stat`.
- Ne pas melanger refactor, changement visuel et correction de bug sans raison.
- Ne pas committer de secrets, fichiers locaux, caches, builds ou changements generes inutiles.
- Ne pas ajouter de trailer `Co-authored-by` pour Codex, OpenAI ou un assistant IA.
- Pull ou merge `main` avant de pousser une branche qui a dure plus qu'une petite session.
- Apres push, ouvrir une PR avec les validations executees et les risques restants.

## iOS local

- Si CocoaPods echoue avec l'erreur Ruby `Logger`, lancer Flutter avec `RUBYOPT=-rlogger`.
- Pour le debug iPhone en wireless, accepter l'autorisation Local Network et preferer l'USB si les interactions ou logs deviennent instables.
