import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/place_search_details.dart';
import 'package:front/domain/entities/place_search_suggestion.dart';
import 'package:front/domain/repositories/place_search_repository.dart';
import 'package:front/domain/usecases/get_place_details_use_case.dart';
import 'package:front/domain/usecases/search_place_suggestions_use_case.dart';

void main() {
  late _FakePlaceSearchRepository repository;

  setUp(() {
    repository = _FakePlaceSearchRepository();
  });

  test('should forward suggestion search parameters to repository', () async {
    final useCase = SearchPlaceSuggestionsUseCase(repository);

    await useCase(
      'paris',
      sessionToken: 'session-1',
      languageCode: 'fr',
      regionCode: 'FR',
    );

    expect(repository.lastQuery, 'paris');
    expect(repository.lastSessionToken, 'session-1');
    expect(repository.lastLanguageCode, 'fr');
    expect(repository.lastRegionCode, 'FR');
  });

  test('should forward place details parameters to repository', () async {
    final useCase = GetPlaceDetailsUseCase(repository);

    await useCase(
      'place-1',
      sessionToken: 'session-2',
      languageCode: 'en',
      regionCode: 'US',
    );

    expect(repository.lastPlaceId, 'place-1');
    expect(repository.lastSessionToken, 'session-2');
    expect(repository.lastLanguageCode, 'en');
    expect(repository.lastRegionCode, 'US');
  });
}

class _FakePlaceSearchRepository implements PlaceSearchRepository {
  String? lastQuery;
  String? lastPlaceId;
  String? lastSessionToken;
  String? lastLanguageCode;
  String? lastRegionCode;

  @override
  Future<Either<Failure, PlaceSearchDetails>> getPlaceDetails(
    String placeId, {
    String? sessionToken,
    String? languageCode,
    String? regionCode,
  }) async {
    lastPlaceId = placeId;
    lastSessionToken = sessionToken;
    lastLanguageCode = languageCode;
    lastRegionCode = regionCode;

    return right(
      const PlaceSearchDetails(
        placeId: 'place-1',
        formattedAddress: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        types: <String>['museum'],
        openingHours: <String>['Monday: 09:00-18:00'],
        rating: 4.8,
        userRatingCount: 1200,
        isOpenNow: true,
      ),
    );
  }

  @override
  Future<Either<Failure, List<PlaceSearchSuggestion>>> searchSuggestions(
    String query, {
    required String sessionToken,
    String? languageCode,
    String? regionCode,
  }) async {
    lastQuery = query;
    lastSessionToken = sessionToken;
    lastLanguageCode = languageCode;
    lastRegionCode = regionCode;

    return right(const <PlaceSearchSuggestion>[
      PlaceSearchSuggestion(
        placeId: 'place-1',
        title: 'Louvre Museum',
        fullText: 'Louvre Museum, Paris, France',
      ),
    ]);
  }
}
