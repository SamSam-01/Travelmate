import 'package:front/domain/entities/place_search_details.dart';
import 'package:front/domain/entities/place_search_suggestion.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class SelectedMapPlace {
  const SelectedMapPlace({
    required this.name,
    required this.sourceLabel,
    required this.longitude,
    required this.latitude,
    this.googlePlaceId,
    this.address,
    this.rating,
    this.reviewCount,
    this.isOpenNow,
    List<String>? openingHours,
    this.photoUrl,
    this.photoAttribution,
    this.category,
    this.group,
    this.icon,
    this.transitMode,
    this.transitStopType,
    this.transitNetwork,
    this.airportCode,
  }) : openingHours = openingHours ?? const <String>[];

  final String name;
  final String sourceLabel;
  final double longitude;
  final double latitude;
  final String? googlePlaceId;
  final String? address;
  final double? rating;
  final int? reviewCount;
  final bool? isOpenNow;
  final List<String> openingHours;
  final String? photoUrl;
  final String? photoAttribution;
  final String? category;
  final String? group;
  final String? icon;
  final String? transitMode;
  final String? transitStopType;
  final String? transitNetwork;
  final String? airportCode;

  static Point? coordinateFromGeometry(Map<String?, Object?> geometry) {
    final rawCoordinates = geometry['coordinates'];
    if (rawCoordinates is! List<Object?> || rawCoordinates.length < 2) {
      return null;
    }

    final longitude = _toDouble(rawCoordinates[0]);
    final latitude = _toDouble(rawCoordinates[1]);
    if (longitude == null || latitude == null) {
      return null;
    }

    return Point(coordinates: Position(longitude, latitude));
  }

  static SelectedMapPlace fromPoi({
    required TypedFeaturesetFeature<StandardPOIs> feature,
    required Point coordinate,
    required String sourceLabel,
  }) {
    return SelectedMapPlace(
      name: feature.name ?? 'Unknown place',
      sourceLabel: sourceLabel,
      longitude: coordinate.coordinates.lng.toDouble(),
      latitude: coordinate.coordinates.lat.toDouble(),
      category: feature.category,
      group: feature.group,
      icon: feature.maki,
      transitMode: feature.transitMode,
      transitStopType: feature.transitStopType,
      transitNetwork: feature.transitNetwork,
      airportCode: feature.airportRef,
    );
  }

  static SelectedMapPlace fromPlaceLabel({
    required TypedFeaturesetFeature<StandardPlaceLabels> feature,
    required Point coordinate,
    required String sourceLabel,
  }) {
    return SelectedMapPlace(
      name: feature.name ?? 'Unknown place',
      sourceLabel: sourceLabel,
      longitude: coordinate.coordinates.lng.toDouble(),
      latitude: coordinate.coordinates.lat.toDouble(),
      category: feature.category,
    );
  }

  static SelectedMapPlace fromGooglePlace({
    required PlaceSearchSuggestion suggestion,
    required PlaceSearchDetails details,
    required String sourceLabel,
  }) {
    return SelectedMapPlace(
      name: suggestion.title,
      sourceLabel: sourceLabel,
      longitude: details.longitude,
      latitude: details.latitude,
      googlePlaceId: details.placeId,
      address: details.formattedAddress,
      rating: details.rating,
      reviewCount: details.userRatingCount,
      isOpenNow: details.isOpenNow,
      openingHours: details.openingHours,
      photoUrl: details.photoUrl,
      photoAttribution: details.photoAttribution,
      category: details.types.isEmpty ? null : details.types.first,
    );
  }

  static double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return null;
  }
}
