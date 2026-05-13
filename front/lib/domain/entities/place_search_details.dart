class PlaceSearchDetails {
  const PlaceSearchDetails({
    required this.placeId,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    List<String>? types,
    List<String>? openingHours,
    this.rating,
    this.userRatingCount,
    this.isOpenNow,
    this.photoUrl,
    this.photoAttribution,
  }) : types = types ?? const <String>[],
       openingHours = openingHours ?? const <String>[];

  final String placeId;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final List<String> types;
  final List<String> openingHours;
  final double? rating;
  final int? userRatingCount;
  final bool? isOpenNow;
  final String? photoUrl;
  final String? photoAttribution;
}
