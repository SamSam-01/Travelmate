import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/datasources/google_places_remote_data_source.dart';

void main() {
  test(
    'should request only essentials fields when loading Google place details',
    () async {
      late String recordedMethod;
      late Uri recordedUri;
      late Map<String, String> recordedHeaders;

      final dataSource = GooglePlacesRemoteDataSource(
        'test-api-key',
        executor:
            ({
              required String method,
              required Uri uri,
              required Map<String, String> headers,
              Map<String, Object?>? body,
            }) async {
              recordedMethod = method;
              recordedUri = uri;
              recordedHeaders = headers;

              return <String, Object?>{
                'id': 'abc123',
                'formattedAddress': 'Paris, France',
                'location': <String, Object?>{
                  'latitude': 48.8566,
                  'longitude': 2.3522,
                },
                'types': <Object?>['museum'],
                'rating': 4.7,
                'userRatingCount': 12843,
                'regularOpeningHours': <String, Object?>{
                  'openNow': true,
                  'weekdayDescriptions': <Object?>[
                    'Monday: 09:00-18:00',
                    'Tuesday: 09:00-18:00',
                  ],
                },
                'photos': <Object?>[
                  <String, Object?>{
                    'name': 'places/abc123/photos/photo-ref',
                    'authorAttributions': <Object?>[
                      <String, Object?>{'displayName': 'John Smith'},
                    ],
                  },
                ],
              };
            },
      );

      final details = await dataSource.getPlaceDetails(
        'abc123',
        sessionToken: 'session-token',
        languageCode: 'fr',
        regionCode: 'FR',
      );

      expect(recordedMethod, 'GET');
      expect(recordedUri.queryParameters['sessionToken'], 'session-token');
      expect(recordedUri.queryParameters['languageCode'], 'fr');
      expect(recordedUri.queryParameters['regionCode'], 'FR');
      expect(
        recordedHeaders['X-Goog-FieldMask'],
        'id,formattedAddress,location,types,'
        'rating,userRatingCount,regularOpeningHours,photos',
      );
      expect(details.formattedAddress, 'Paris, France');
      expect(details.types, <String>['museum']);
      expect(details.openingHours, <String>[
        'Monday: 09:00-18:00',
        'Tuesday: 09:00-18:00',
      ]);
      expect(details.rating, 4.7);
      expect(details.userRatingCount, 12843);
      expect(details.isOpenNow, isTrue);
      expect(
        details.photoUrl,
        'https://places.googleapis.com/v1/places/abc123/photos/photo-ref/media'
        '?maxWidthPx=1200&key=test-api-key',
      );
      expect(details.photoAttribution, 'John Smith');
    },
  );
}
