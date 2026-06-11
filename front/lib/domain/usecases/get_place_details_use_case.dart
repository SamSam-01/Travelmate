import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/domain/entities/place_search_details.dart';
import 'package:front/domain/repositories/place_search_repository.dart';

class GetPlaceDetailsUseCase {
  const GetPlaceDetailsUseCase(this._repository);

  final PlaceSearchRepository _repository;

  Future<Either<Failure, PlaceSearchDetails>> call(
    String placeId, {
    String? sessionToken,
    String? languageCode,
    String? regionCode,
  }) {
    return _repository.getPlaceDetails(
      placeId,
      sessionToken: sessionToken,
      languageCode: languageCode,
      regionCode: regionCode,
    );
  }
}
