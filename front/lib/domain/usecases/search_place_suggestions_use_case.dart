import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/place_search_suggestion.dart';
import 'package:front/domain/repositories/place_search_repository.dart';

class SearchPlaceSuggestionsUseCase {
  const SearchPlaceSuggestionsUseCase(this._repository);

  final PlaceSearchRepository _repository;

  Future<Either<Failure, List<PlaceSearchSuggestion>>> call(
    String query, {
    required String sessionToken,
    String? languageCode,
    String? regionCode,
  }) {
    return _repository.searchSuggestions(
      query,
      sessionToken: sessionToken,
      languageCode: languageCode,
      regionCode: regionCode,
    );
  }
}
