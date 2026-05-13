# front

A new Flutter project.

## Environment

Copy `.env.template` to `.env`, then fill:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
MAPBOX_ACCESS_TOKEN=
GOOGLE_PLACES_API_KEY=
PASSWORD_RESET_REDIRECT_URL=
```

`PASSWORD_RESET_REDIRECT_URL` is optional. On web, the app falls back to the
current origin with `?mode=reset-password`.

Run the app with:

```sh
flutter run --dart-define-from-file=.env
```

`GOOGLE_PLACES_API_KEY` is optional. If provided, the Maps screen enables a
Google Places search flow limited to Autocomplete + Place Details Essentials to
keep usage costs low.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
