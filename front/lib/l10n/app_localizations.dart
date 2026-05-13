import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'CRAZER'**
  String get appTitle;

  /// No description provided for @navigationHome.
  ///
  /// In fr, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationMaps.
  ///
  /// In fr, this message translates to:
  /// **'Maps'**
  String get navigationMaps;

  /// No description provided for @navigationProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navigationProfile;

  /// No description provided for @navigationFriends.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get navigationFriends;

  /// No description provided for @homeTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre compagnon de voyage idéal'**
  String get homeTagline;

  /// No description provided for @exploreWithoutAccount.
  ///
  /// In fr, this message translates to:
  /// **'Explorer sans compte'**
  String get exploreWithoutAccount;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @goToAccount.
  ///
  /// In fr, this message translates to:
  /// **'Accéder à mon compte'**
  String get goToAccount;

  /// No description provided for @featureComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité d\'exploration à venir !'**
  String get featureComingSoon;

  /// No description provided for @continueToMap.
  ///
  /// In fr, this message translates to:
  /// **'Continuer vers la carte'**
  String get continueToMap;

  /// No description provided for @mapsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Maps'**
  String get mapsTitle;

  /// No description provided for @mapsMissingTokenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Token Mapbox manquant'**
  String get mapsMissingTokenTitle;

  /// No description provided for @mapsMissingTokenMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute MAPBOX_ACCESS_TOKEN dans tes dart-defines pour afficher la carte.'**
  String get mapsMissingTokenMessage;

  /// No description provided for @mapsUnavailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte non disponible ici'**
  String get mapsUnavailableTitle;

  /// No description provided for @mapsUnavailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'La vue Mapbox est disponible sur iOS et Android, pas dans cet environnement.'**
  String get mapsUnavailableMessage;

  /// No description provided for @mapsRecenterTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Recentrer'**
  String get mapsRecenterTooltip;

  /// No description provided for @mapsPlaceDetailsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un lieu'**
  String get mapsPlaceDetailsEmptyTitle;

  /// No description provided for @mapsPlaceDetailsEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Touchez un point d\'intérêt ou un libellé sur la carte pour afficher ses informations.'**
  String get mapsPlaceDetailsEmptyMessage;

  /// No description provided for @mapsPlaceDetailsSourcePoi.
  ///
  /// In fr, this message translates to:
  /// **'Point d\'intérêt'**
  String get mapsPlaceDetailsSourcePoi;

  /// No description provided for @mapsPlaceDetailsSourcePlace.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get mapsPlaceDetailsSourcePlace;

  /// No description provided for @mapsPlaceDetailsSourceGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Google Places'**
  String get mapsPlaceDetailsSourceGoogle;

  /// No description provided for @mapsPlaceDetailsAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get mapsPlaceDetailsAddress;

  /// No description provided for @mapsPlaceDetailsPlaceId.
  ///
  /// In fr, this message translates to:
  /// **'Place ID'**
  String get mapsPlaceDetailsPlaceId;

  /// No description provided for @mapsPlaceDetailsRating.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get mapsPlaceDetailsRating;

  /// No description provided for @mapsPlaceDetailsReviewCount.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get mapsPlaceDetailsReviewCount;

  /// No description provided for @mapsPlaceDetailsOpenNow.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get mapsPlaceDetailsOpenNow;

  /// No description provided for @mapsPlaceDetailsOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert'**
  String get mapsPlaceDetailsOpen;

  /// No description provided for @mapsPlaceDetailsClosed.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get mapsPlaceDetailsClosed;

  /// No description provided for @mapsPlaceDetailsCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get mapsPlaceDetailsCategory;

  /// No description provided for @mapsPlaceDetailsGroup.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get mapsPlaceDetailsGroup;

  /// No description provided for @mapsPlaceDetailsIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get mapsPlaceDetailsIcon;

  /// No description provided for @mapsPlaceDetailsTransitMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode de transport'**
  String get mapsPlaceDetailsTransitMode;

  /// No description provided for @mapsPlaceDetailsTransitStopType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'arrêt'**
  String get mapsPlaceDetailsTransitStopType;

  /// No description provided for @mapsPlaceDetailsTransitNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Réseau'**
  String get mapsPlaceDetailsTransitNetwork;

  /// No description provided for @mapsPlaceDetailsAirportCode.
  ///
  /// In fr, this message translates to:
  /// **'Code aéroport'**
  String get mapsPlaceDetailsAirportCode;

  /// No description provided for @mapsPlaceDetailsLongitude.
  ///
  /// In fr, this message translates to:
  /// **'Longitude'**
  String get mapsPlaceDetailsLongitude;

  /// No description provided for @mapsPlaceDetailsLatitude.
  ///
  /// In fr, this message translates to:
  /// **'Latitude'**
  String get mapsPlaceDetailsLatitude;

  /// No description provided for @mapsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un lieu'**
  String get mapsSearchHint;

  /// No description provided for @mapsSearchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat Google Places pour cette recherche.'**
  String get mapsSearchEmpty;

  /// No description provided for @mapsSearchDisabledMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute GOOGLE_PLACES_API_KEY pour activer la recherche de lieux à bas coût.'**
  String get mapsSearchDisabledMessage;

  /// No description provided for @mapsSearchPoweredByGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Powered by Google'**
  String get mapsSearchPoweredByGoogle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un nouveau mot de passe'**
  String get resetPasswordHeadline;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une fois valide, votre mot de passe sera mis a jour immediatement.'**
  String get resetPasswordDescription;

  /// No description provided for @resetPasswordField.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get resetPasswordField;

  /// No description provided for @resetPasswordConfirmField.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get resetPasswordConfirmField;

  /// No description provided for @resetPasswordSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Mettre a jour le mot de passe'**
  String get resetPasswordSubmit;

  /// No description provided for @resetPasswordBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour a la connexion'**
  String get resetPasswordBackToLogin;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe mis a jour avec succes.'**
  String get resetPasswordSuccess;

  /// No description provided for @loginCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get loginCreateAccount;

  /// No description provided for @loginAlreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get loginAlreadyHaveAccount;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? Créer un compte'**
  String get loginNoAccount;

  /// No description provided for @loginEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPassword;

  /// No description provided for @loginUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get loginUsername;

  /// No description provided for @loginUsernameHint.
  ///
  /// In fr, this message translates to:
  /// **'2 à 20 caractères, lettres, chiffres, _ et .'**
  String get loginUsernameHint;

  /// No description provided for @loginSignUpSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé avec succès !'**
  String get loginSignUpSuccess;

  /// No description provided for @loginSignInSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie !'**
  String get loginSignInSuccess;

  /// No description provided for @loginCheckEmail.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre email pour confirmer votre compte'**
  String get loginCheckEmail;

  /// No description provided for @loginUnexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inattendue'**
  String get loginUnexpectedError;

  /// No description provided for @loginEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez votre email'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez votre mot de passe'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'6 caracteres minimum'**
  String get loginPasswordTooShort;

  /// No description provided for @loginUsernameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez votre nom d\'utilisateur'**
  String get loginUsernameRequired;

  /// No description provided for @loginUsernameInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez 2 à 20 caractères: lettres, chiffres, _ ou .'**
  String get loginUsernameInvalid;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @backHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get backHome;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get profileUsername;

  /// No description provided for @profileDisplayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché'**
  String get profileDisplayName;

  /// No description provided for @profileAvatarUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL de l\'avatar'**
  String get profileAvatarUrl;

  /// No description provided for @profilePrivate.
  ///
  /// In fr, this message translates to:
  /// **'Profil privé'**
  String get profilePrivate;

  /// No description provided for @profileUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get profileUpdate;

  /// No description provided for @profileSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement...'**
  String get profileSaving;

  /// No description provided for @profileSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileSignOut;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès !'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileLoginRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connexion requise'**
  String get profileLoginRequired;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @friendsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get friendsTitle;

  /// No description provided for @friendsTab.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get friendsTab;

  /// No description provided for @requestsTab.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get requestsTab;

  /// No description provided for @friendsSearchAction.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get friendsSearchAction;

  /// No description provided for @friendsSearchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un utilisateur'**
  String get friendsSearchTitle;

  /// No description provided for @friendsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Recherche par username'**
  String get friendsSearchHint;

  /// No description provided for @friendsSearchHelper.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez au moins 2 caractères.'**
  String get friendsSearchHelper;

  /// No description provided for @friendsSearchEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur trouvé.'**
  String get friendsSearchEmpty;

  /// No description provided for @friendsListEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ami pour le moment.'**
  String get friendsListEmpty;

  /// No description provided for @requestsListEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande en attente.'**
  String get requestsListEmpty;

  /// No description provided for @friendActionSend.
  ///
  /// In fr, this message translates to:
  /// **'Demander en ami'**
  String get friendActionSend;

  /// No description provided for @friendActionPending.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get friendActionPending;

  /// No description provided for @friendActionRequestReceived.
  ///
  /// In fr, this message translates to:
  /// **'Demande reçue'**
  String get friendActionRequestReceived;

  /// No description provided for @friendActionFriends.
  ///
  /// In fr, this message translates to:
  /// **'Déjà ami'**
  String get friendActionFriends;

  /// No description provided for @friendActionAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get friendActionAccept;

  /// No description provided for @friendActionDecline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get friendActionDecline;

  /// No description provided for @friendActionResponding.
  ///
  /// In fr, this message translates to:
  /// **'Traitement...'**
  String get friendActionResponding;

  /// No description provided for @friendRequestFrom.
  ///
  /// In fr, this message translates to:
  /// **'Demande de {username}'**
  String friendRequestFrom(String username);

  /// No description provided for @friendRequestSentSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée.'**
  String get friendRequestSentSuccess;

  /// No description provided for @friendRequestAcceptedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Demande acceptée.'**
  String get friendRequestAcceptedSuccess;

  /// No description provided for @friendRequestDeclinedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Demande refusée.'**
  String get friendRequestDeclinedSuccess;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get errorGeneric;

  /// No description provided for @validationNewPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez votre nouveau mot de passe'**
  String get validationNewPasswordRequired;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre nouveau mot de passe'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @activitiesLoadErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les activités'**
  String get activitiesLoadErrorTitle;

  /// No description provided for @activitiesEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité disponible'**
  String get activitiesEmptyTitle;

  /// No description provided for @activitiesEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Reviens un peu plus tard ou relance le chargement.'**
  String get activitiesEmptyMessage;

  /// No description provided for @activitiesDiscoverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activités à découvrir'**
  String get activitiesDiscoverTitle;

  /// No description provided for @activitiesDiscoverSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez quoi faire maintenant'**
  String get activitiesDiscoverSubtitle;

  /// No description provided for @activitiesPlannedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sorties planifiées'**
  String get activitiesPlannedTitle;

  /// No description provided for @activitiesPlannedSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos prochaines sorties à venir'**
  String get activitiesPlannedSubtitle;

  /// No description provided for @searchResultPrivate.
  ///
  /// In fr, this message translates to:
  /// **'Profil privé'**
  String get searchResultPrivate;

  /// No description provided for @searchResultPublic.
  ///
  /// In fr, this message translates to:
  /// **'Profil public'**
  String get searchResultPublic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
