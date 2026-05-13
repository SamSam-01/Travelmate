import 'package:front/domain/entities/place_search_details.dart';

class PlaceSearchDetailsModel extends PlaceSearchDetails {
  const PlaceSearchDetailsModel({
    required super.placeId,
    required super.formattedAddress,
    required super.latitude,
    required super.longitude,
    required super.types,
    required super.openingHours,
    super.rating,
    super.userRatingCount,
    super.isOpenNow,
    super.photoUrl,
    super.photoAttribution,
  });

  factory PlaceSearchDetailsModel.fromJson(
    Map<String, Object?> json, {
    required String apiKey,
  }) {
    final location = json['location'] as Map<Object?, Object?>? ?? const {};
    final rawTypes = json['types'] as List<Object?>? ?? const [];
    final openingHours =
        json['regularOpeningHours'] as Map<Object?, Object?>? ?? const {};
    final weekdayDescriptions =
        openingHours['weekdayDescriptions'] as List<Object?>? ?? const [];
    final photos = json['photos'] as List<Object?>? ?? const [];
    final firstPhoto = photos.isEmpty
        ? null
        : photos.first as Map<Object?, Object?>?;
    final authorAttributions =
        firstPhoto?['authorAttributions'] as List<Object?>? ?? const [];
    final firstAttribution = authorAttributions.isEmpty
        ? null
        : authorAttributions.first as Map<Object?, Object?>?;
    final photoName = firstPhoto?['name'] as String?;

    return PlaceSearchDetailsModel(
      placeId: json['id'] as String? ?? '',
      formattedAddress: json['formattedAddress'] as String? ?? '',
      latitude: (location['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (location['longitude'] as num?)?.toDouble() ?? 0,
      types: rawTypes.whereType<String>().toList(growable: false),
      openingHours: weekdayDescriptions.whereType<String>().toList(
        growable: false,
      ),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount: json['userRatingCount'] as int?,
      isOpenNow: openingHours['openNow'] as bool?,
      photoUrl: photoName == null
          ? null
          : 'https://places.googleapis.com/v1/$photoName/media'
                '?maxWidthPx=1200&key=$apiKey',
      photoAttribution: firstAttribution?['displayName'] as String?,
    );
  }
}
