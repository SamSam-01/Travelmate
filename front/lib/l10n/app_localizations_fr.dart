// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CRAZER';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationMaps => 'Maps';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get navigationFriends => 'Amis';

  @override
  String get homeTagline => 'Votre compagnon de voyage idéal';

  @override
  String get exploreWithoutAccount => 'Explorer sans compte';

  @override
  String get signIn => 'Se connecter';

  @override
  String get goToAccount => 'Accéder à mon compte';

  @override
  String get featureComingSoon => 'Fonctionnalité d\'exploration à venir !';

  @override
  String get continueToMap => 'Continuer vers la carte';

  @override
  String get mapsTitle => 'Maps';

  @override
  String get mapsMissingTokenTitle => 'Token Mapbox manquant';

  @override
  String get mapsMissingTokenMessage =>
      'Ajoute MAPBOX_ACCESS_TOKEN dans tes dart-defines pour afficher la carte.';

  @override
  String get mapsUnavailableTitle => 'Carte non disponible ici';

  @override
  String get mapsUnavailableMessage =>
      'La vue Mapbox est disponible sur iOS et Android, pas dans cet environnement.';

  @override
  String get mapsRecenterTooltip => 'Recentrer';

  @override
  String get mapsPlaceDetailsEmptyTitle => 'Sélectionnez un lieu';

  @override
  String get mapsPlaceDetailsEmptyMessage =>
      'Touchez un point d\'intérêt ou un libellé sur la carte pour afficher ses informations.';

  @override
  String get mapsPlaceDetailsSourcePoi => 'Point d\'intérêt';

  @override
  String get mapsPlaceDetailsSourcePlace => 'Lieu';

  @override
  String get mapsPlaceDetailsSourceGoogle => 'Google Places';

  @override
  String get mapsPlaceDetailsAddress => 'Adresse';

  @override
  String get mapsPlaceDetailsPlaceId => 'Place ID';

  @override
  String get mapsPlaceDetailsRating => 'Note';

  @override
  String get mapsPlaceDetailsReviewCount => 'Avis';

  @override
  String get mapsPlaceDetailsOpenNow => 'Statut';

  @override
  String get mapsPlaceDetailsOpen => 'Ouvert';

  @override
  String get mapsPlaceDetailsClosed => 'Fermé';

  @override
  String get mapsPlaceDetailsCategory => 'Catégorie';

  @override
  String get mapsPlaceDetailsGroup => 'Groupe';

  @override
  String get mapsPlaceDetailsIcon => 'Icône';

  @override
  String get mapsPlaceDetailsTransitMode => 'Mode de transport';

  @override
  String get mapsPlaceDetailsTransitStopType => 'Type d\'arrêt';

  @override
  String get mapsPlaceDetailsTransitNetwork => 'Réseau';

  @override
  String get mapsPlaceDetailsAirportCode => 'Code aéroport';

  @override
  String get mapsPlaceDetailsLongitude => 'Longitude';

  @override
  String get mapsPlaceDetailsLatitude => 'Latitude';

  @override
  String get mapsSearchHint => 'Rechercher un lieu';

  @override
  String get mapsSearchEmpty =>
      'Aucun résultat Google Places pour cette recherche.';

  @override
  String get mapsSearchDisabledMessage =>
      'Ajoute GOOGLE_PLACES_API_KEY pour activer la recherche de lieux à bas coût.';

  @override
  String get mapsSearchPoweredByGoogle => 'Powered by Google';

  @override
  String get resetPasswordTitle => 'Nouveau mot de passe';

  @override
  String get resetPasswordHeadline => 'Choisissez un nouveau mot de passe';

  @override
  String get resetPasswordDescription =>
      'Une fois valide, votre mot de passe sera mis a jour immediatement.';

  @override
  String get resetPasswordField => 'Nouveau mot de passe';

  @override
  String get resetPasswordConfirmField => 'Confirmer le mot de passe';

  @override
  String get resetPasswordSubmit => 'Mettre a jour le mot de passe';

  @override
  String get resetPasswordBackToLogin => 'Retour a la connexion';

  @override
  String get resetPasswordSuccess => 'Mot de passe mis a jour avec succes.';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get loginAlreadyHaveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get loginNoAccount => 'Pas de compte ? Créer un compte';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginUsername => 'Nom d\'utilisateur';

  @override
  String get loginUsernameHint =>
      '2 à 20 caractères, lettres, chiffres, _ et .';

  @override
  String get loginSignUpSuccess => 'Compte créé avec succès !';

  @override
  String get loginSignInSuccess => 'Connexion réussie !';

  @override
  String get loginCheckEmail =>
      'Vérifiez votre email pour confirmer votre compte';

  @override
  String get loginUnexpectedError => 'Erreur inattendue';

  @override
  String get loginEmailRequired => 'Renseignez votre email';

  @override
  String get loginEmailInvalid => 'Email invalide';

  @override
  String get loginPasswordRequired => 'Renseignez votre mot de passe';

  @override
  String get loginPasswordTooShort => '6 caracteres minimum';

  @override
  String get loginUsernameRequired => 'Renseignez votre nom d\'utilisateur';

  @override
  String get loginUsernameInvalid =>
      'Utilisez 2 à 20 caractères: lettres, chiffres, _ ou .';

  @override
  String get back => 'Retour';

  @override
  String get backHome => 'Retour à l\'accueil';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUsername => 'Nom d\'utilisateur';

  @override
  String get profileDisplayName => 'Nom affiché';

  @override
  String get profileAvatarUrl => 'URL de l\'avatar';

  @override
  String get profilePrivate => 'Profil privé';

  @override
  String get profileUpdate => 'Mettre à jour';

  @override
  String get profileSaving => 'Enregistrement...';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileUpdatedSuccess => 'Profil mis à jour avec succès !';

  @override
  String get profileLoginRequired => 'Connexion requise';

  @override
  String get loading => 'Chargement...';

  @override
  String get friendsTitle => 'Amis';

  @override
  String get friendsTab => 'Amis';

  @override
  String get requestsTab => 'Demandes';

  @override
  String get friendsSearchAction => 'Rechercher';

  @override
  String get friendsSearchTitle => 'Rechercher un utilisateur';

  @override
  String get friendsSearchHint => 'Recherche par username';

  @override
  String get friendsSearchHelper => 'Saisissez au moins 2 caractères.';

  @override
  String get friendsSearchEmpty => 'Aucun utilisateur trouvé.';

  @override
  String get friendsListEmpty => 'Aucun ami pour le moment.';

  @override
  String get requestsListEmpty => 'Aucune demande en attente.';

  @override
  String get friendActionSend => 'Demander en ami';

  @override
  String get friendActionPending => 'Demande envoyée';

  @override
  String get friendActionRequestReceived => 'Demande reçue';

  @override
  String get friendActionFriends => 'Déjà ami';

  @override
  String get friendActionAccept => 'Accepter';

  @override
  String get friendActionDecline => 'Refuser';

  @override
  String get friendActionResponding => 'Traitement...';

  @override
  String friendRequestFrom(String username) {
    return 'Demande de $username';
  }

  @override
  String get friendRequestSentSuccess => 'Demande envoyée.';

  @override
  String get friendRequestAcceptedSuccess => 'Demande acceptée.';

  @override
  String get friendRequestDeclinedSuccess => 'Demande refusée.';

  @override
  String get errorGeneric => 'Une erreur est survenue.';

  @override
  String get validationNewPasswordRequired =>
      'Renseignez votre nouveau mot de passe';

  @override
  String get validationConfirmPasswordRequired =>
      'Confirmez votre nouveau mot de passe';

  @override
  String get validationPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get retry => 'Réessayer';

  @override
  String get activitiesLoadErrorTitle => 'Impossible de charger les activités';

  @override
  String get activitiesEmptyTitle => 'Aucune activité disponible';

  @override
  String get activitiesEmptyMessage =>
      'Reviens un peu plus tard ou relance le chargement.';

  @override
  String get activitiesDiscoverTitle => 'Activités à découvrir';

  @override
  String get activitiesDiscoverSubtitle => 'Trouvez quoi faire maintenant';

  @override
  String get activitiesPlannedTitle => 'Sorties planifiées';

  @override
  String get activitiesPlannedSubtitle => 'Vos prochaines sorties à venir';

  @override
  String get searchResultPrivate => 'Profil privé';

  @override
  String get searchResultPublic => 'Profil public';
}
