import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/place_search_details.dart';
import 'package:front/domain/entities/place_search_suggestion.dart';

abstract class PlaceSearchRepository {
  Future<Either<Failure, List<PlaceSearchSuggestion>>> searchSuggestions(
    String query, {
    required String sessionToken,
    String? languageCode,
    String? regionCode,
  });

  Future<Either<Failure, PlaceSearchDetails>> getPlaceDetails(
    String placeId, {
    String? sessionToken,
    String? languageCode,
    String? regionCode,
  });
}
