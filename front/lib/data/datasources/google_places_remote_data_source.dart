import 'dart:convert';
import 'dart:io';

import 'package:front/data/models/place_search_details_model.dart';
import 'package:front/data/models/place_search_suggestion_model.dart';

typedef GooglePlacesRequestExecutor =
    Future<Map<String, Object?>> Function({
      required String method,
      required Uri uri,
      required Map<String, String> headers,
      Map<String, Object?>? body,
    });

class GooglePlacesRemoteDataSource {
  GooglePlacesRemoteDataSource(
    this._apiKey, {
    GooglePlacesRequestExecutor? executor,
  }) : _executor = executor ?? _defaultExecutor;

  static const int maxSuggestions = 5;
  static const String _autocompleteFieldMask =
      'suggestions.placePrediction.placeId,'
      'suggestions.placePrediction.text.text,'
      'suggestions.placePrediction.structuredFormat.mainText.text,'
      'suggestions.placePrediction.structuredFormat.secondaryText.text';
  static const String _detailsFieldMask =
      'id,formattedAddress,location,types,'
      'rating,userRatingCount,regularOpeningHours,photos';

  final String _apiKey;
  final GooglePlacesRequestExecutor _executor;

  Future<List<PlaceSearchSuggestionModel>> searchSuggestions(
    String query, {
    required String sessionToken,
    String? languageCode,
    String? regionCode,
  }) async {
    final response = await _executor(
      method: 'POST',
      uri: Uri.https('places.googleapis.com', '/v1/places:autocomplete'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': _autocompleteFieldMask,
      },
      body: <String, Object?>{
        'input': query,
        'sessionToken': sessionToken,
        'languageCode': languageCode,
        'regionCode': regionCode,
        'includeQueryPredictions': false,
      }..removeWhere((_, value) => value == null),
    );

    final suggestions = response['suggestions'] as List<Object?>? ?? const [];
    return suggestions
        .map((item) => item as Map<Object?, Object?>)
        .map((item) => item['placePrediction'] as Map<Object?, Object?>?)
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) =>
              PlaceSearchSuggestionModel.fromJson(item.cast<String, Object?>()),
        )
        .where((item) => item.placeId.isNotEmpty && item.title.isNotEmpty)
        .take(maxSuggestions)
        .toList(growable: false);
  }

  Future<PlaceSearchDetailsModel> getPlaceDetails(
    String placeId, {
    String? sessionToken,
    String? languageCode,
    String? regionCode,
  }) async {
    final queryParameters = <String, String>{
      if (languageCode != null) 'languageCode': languageCode,
      if (regionCode != null) 'regionCode': regionCode,
      if (sessionToken != null) 'sessionToken': sessionToken,
    };

    return PlaceSearchDetailsModel.fromJson(
      await _executor(
        method: 'GET',
        uri: Uri.https(
          'places.googleapis.com',
          '/v1/places/$placeId',
          queryParameters,
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': _detailsFieldMask,
        },
      ),
      apiKey: _apiKey,
    );
  }

  static Future<Map<String, Object?>> _defaultExecutor({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Map<String, Object?>? body,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.openUrl(method, uri);
      headers.forEach(request.headers.set);

      if (body != null && body.isNotEmpty) {
        request.write(jsonEncode(body));
      }

      final response = await request.close();
      final rawResponse = await response.transform(utf8.decoder).join();
      final decodedResponse = rawResponse.isEmpty
          ? <String, Object?>{}
          : jsonDecode(rawResponse) as Map<String, Object?>;

      if (response.statusCode >= HttpStatus.badRequest) {
        final error = decodedResponse['error'] as Map<Object?, Object?>?;
        throw GooglePlacesRemoteDataSourceException(
          (error?['message'] as String?) ?? 'Google Places request failed.',
        );
      }

      return decodedResponse;
    } on SocketException {
      throw const GooglePlacesRemoteDataSourceException(
        'Unable to reach Google Places.',
      );
    } on HttpException {
      throw const GooglePlacesRemoteDataSourceException(
        'Google Places request failed.',
      );
    } finally {
      client.close(force: true);
    }
  }
}

class GooglePlacesRemoteDataSourceException implements Exception {
  const GooglePlacesRemoteDataSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}
