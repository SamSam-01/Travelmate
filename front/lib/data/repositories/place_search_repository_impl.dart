import 'package:fpdart/fpdart.dart';
import 'package:front/core/errors/failures.dart';
import 'package:front/data/datasources/google_places_remote_data_source.dart';
import 'package:front/domain/entities/place_search_details.dart';
import 'package:front/domain/entities/place_search_suggestion.dart';
import 'package:front/domain/repositories/place_search_repository.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  const PlaceSearchRepositoryImpl(this._remoteDataSource);

  final GooglePlacesRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, PlaceSearchDetails>> getPlaceDetails(
    String placeId, {
    String? sessionToken,
    String? languageCode,
    String? regionCode,
  }) async {
    try {
      return right(
        await _remoteDataSource.getPlaceDetails(
          placeId,
          sessionToken: sessionToken,
          languageCode: languageCode,
          regionCode: regionCode,
        ),
      );
    } on GooglePlacesRemoteDataSourceException catch (error) {
      return left(Failure(error.message));
    } catch (_) {
      return const Left(Failure('Unexpected place details error.'));
    }
  }

  @override
  Future<Either<Failure, List<PlaceSearchSuggestion>>> searchSuggestions(
    String query, {
    required String sessionToken,
    String? languageCode,
    String? regionCode,
  }) async {
    try {
      return right(
        await _remoteDataSource.searchSuggestions(
          query,
          sessionToken: sessionToken,
          languageCode: languageCode,
          regionCode: regionCode,
        ),
      );
    } on GooglePlacesRemoteDataSourceException catch (error) {
      return left(Failure(error.message));
    } catch (_) {
      return const Left(Failure('Unexpected place search error.'));
    }
  }
}
