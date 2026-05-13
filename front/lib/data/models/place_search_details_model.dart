import 'package:front/domain/entities/place_search_details.dart';

class PlaceSearchDetailsModel extends PlaceSearchDetails {
  const PlaceSearchDetailsModel({
    required super.placeId,
    required super.formattedAddress,
    required super.latitude,
    required super.longitude,
    required super.types,
  });

  factory PlaceSearchDetailsModel.fromJson(Map<String, Object?> json) {
    final location = json['location'] as Map<Object?, Object?>? ?? const {};
    final rawTypes = json['types'] as List<Object?>? ?? const [];

    return PlaceSearchDetailsModel(
      placeId: json['id'] as String? ?? '',
      formattedAddress: json['formattedAddress'] as String? ?? '',
      latitude: (location['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (location['longitude'] as num?)?.toDouble() ?? 0,
      types: rawTypes.whereType<String>().toList(growable: false),
    );
  }
}
