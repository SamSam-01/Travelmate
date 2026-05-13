// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CRAZER';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationMaps => 'Maps';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get navigationFriends => 'Friends';

  @override
  String get homeTagline => 'Your ideal travel companion';

  @override
  String get exploreWithoutAccount => 'Explore without an account';

  @override
  String get signIn => 'Sign in';

  @override
  String get goToAccount => 'Go to my account';

  @override
  String get featureComingSoon => 'Explore mode is coming soon!';

  @override
  String get continueToMap => 'Continue to map';

  @override
  String get mapsTitle => 'Maps';

  @override
  String get mapsMissingTokenTitle => 'Missing Mapbox token';

  @override
  String get mapsMissingTokenMessage =>
      'Add MAPBOX_ACCESS_TOKEN to your dart-defines to display the map.';

  @override
  String get mapsUnavailableTitle => 'Map unavailable here';

  @override
  String get mapsUnavailableMessage =>
      'The Mapbox view is available on iOS and Android, not in this environment.';

  @override
  String get mapsRecenterTooltip => 'Recenter';

  @override
  String get mapsPlaceDetailsEmptyTitle => 'Select a place';

  @override
  String get mapsPlaceDetailsEmptyMessage =>
      'Tap a point of interest or place label on the map to display its details.';

  @override
  String get mapsPlaceDetailsSourcePoi => 'Point of interest';

  @override
  String get mapsPlaceDetailsSourcePlace => 'Place';

  @override
  String get mapsPlaceDetailsSourceGoogle => 'Google Places';

  @override
  String get mapsPlaceDetailsAddress => 'Address';

  @override
  String get mapsPlaceDetailsPlaceId => 'Place ID';

  @override
  String get mapsPlaceDetailsRating => 'Rating';

  @override
  String get mapsPlaceDetailsReviewCount => 'Reviews';

  @override
  String get mapsPlaceDetailsOpenNow => 'Status';

  @override
  String get mapsPlaceDetailsOpen => 'Open';

  @override
  String get mapsPlaceDetailsClosed => 'Closed';

  @override
  String get mapsPlaceDetailsCategory => 'Category';

  @override
  String get mapsPlaceDetailsGroup => 'Group';

  @override
  String get mapsPlaceDetailsIcon => 'Icon';

  @override
  String get mapsPlaceDetailsTransitMode => 'Transit mode';

  @override
  String get mapsPlaceDetailsTransitStopType => 'Stop type';

  @override
  String get mapsPlaceDetailsTransitNetwork => 'Network';

  @override
  String get mapsPlaceDetailsAirportCode => 'Airport code';

  @override
  String get mapsPlaceDetailsLongitude => 'Longitude';

  @override
  String get mapsPlaceDetailsLatitude => 'Latitude';

  @override
  String get mapsSearchHint => 'Search for a place';

  @override
  String get mapsSearchEmpty => 'No Google Places result for this query.';

  @override
  String get mapsSearchDisabledMessage =>
      'Add GOOGLE_PLACES_API_KEY to enable low-cost place search.';

  @override
  String get mapsSearchPoweredByGoogle => 'Powered by Google';

  @override
  String get resetPasswordTitle => 'New password';

  @override
  String get resetPasswordHeadline => 'Choose a new password';

  @override
  String get resetPasswordDescription =>
      'Once valid, your password will be updated immediately.';

  @override
  String get resetPasswordField => 'New password';

  @override
  String get resetPasswordConfirmField => 'Confirm password';

  @override
  String get resetPasswordSubmit => 'Update password';

  @override
  String get resetPasswordBackToLogin => 'Back to sign in';

  @override
  String get resetPasswordSuccess => 'Password updated successfully.';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get loginAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get loginNoAccount => 'No account? Create one';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginUsernameHint =>
      '2 to 20 characters, letters, numbers, _ and .';

  @override
  String get loginSignUpSuccess => 'Account created successfully!';

  @override
  String get loginSignInSuccess => 'Signed in successfully!';

  @override
  String get loginCheckEmail => 'Check your email to confirm your account';

  @override
  String get loginUnexpectedError => 'Unexpected error';

  @override
  String get loginEmailRequired => 'Enter your email';

  @override
  String get loginEmailInvalid => 'Invalid email';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginPasswordTooShort => '6 characters minimum';

  @override
  String get loginUsernameRequired => 'Enter your username';

  @override
  String get loginUsernameInvalid =>
      'Use 2 to 20 characters: letters, numbers, _ or .';

  @override
  String get back => 'Back';

  @override
  String get backHome => 'Back to home';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileUsername => 'Username';

  @override
  String get profileDisplayName => 'Display name';

  @override
  String get profileAvatarUrl => 'Avatar URL';

  @override
  String get profilePrivate => 'Private profile';

  @override
  String get profileUpdate => 'Update';

  @override
  String get profileSaving => 'Saving...';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get profileLoginRequired => 'Sign-in required';

  @override
  String get loading => 'Loading...';

  @override
  String get friendsTitle => 'Friends';

  @override
  String get friendsTab => 'Friends';

  @override
  String get requestsTab => 'Requests';

  @override
  String get friendsSearchAction => 'Search';

  @override
  String get friendsSearchTitle => 'Search user';

  @override
  String get friendsSearchHint => 'Search by username';

  @override
  String get friendsSearchHelper => 'Enter at least 2 characters.';

  @override
  String get friendsSearchEmpty => 'No users found.';

  @override
  String get friendsListEmpty => 'No friends yet.';

  @override
  String get requestsListEmpty => 'No pending requests.';

  @override
  String get friendActionSend => 'Add friend';

  @override
  String get friendActionPending => 'Request sent';

  @override
  String get friendActionRequestReceived => 'Request received';

  @override
  String get friendActionFriends => 'Already friends';

  @override
  String get friendActionAccept => 'Accept';

  @override
  String get friendActionDecline => 'Decline';

  @override
  String get friendActionResponding => 'Processing...';

  @override
  String friendRequestFrom(String username) {
    return 'Request from $username';
  }

  @override
  String get friendRequestSentSuccess => 'Request sent.';

  @override
  String get friendRequestAcceptedSuccess => 'Request accepted.';

  @override
  String get friendRequestDeclinedSuccess => 'Request declined.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get validationNewPasswordRequired => 'Enter your new password';

  @override
  String get validationConfirmPasswordRequired => 'Confirm your new password';

  @override
  String get validationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get retry => 'Retry';

  @override
  String get activitiesLoadErrorTitle => 'Unable to load activities';

  @override
  String get activitiesEmptyTitle => 'No activities available';

  @override
  String get activitiesEmptyMessage => 'Come back later or retry the loading.';

  @override
  String get activitiesDiscoverTitle => 'Activities to discover';

  @override
  String get activitiesDiscoverSubtitle => 'Find something to do right now';

  @override
  String get activitiesPlannedTitle => 'Planned outings';

  @override
  String get activitiesPlannedSubtitle => 'Your next upcoming outings';

  @override
  String get searchResultPrivate => 'Private profile';

  @override
  String get searchResultPublic => 'Public profile';
}
