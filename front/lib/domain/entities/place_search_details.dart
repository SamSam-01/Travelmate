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
  }) : _types = types,
       _openingHours = openingHours;

  final String placeId;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final List<String>? _types;
  final List<String>? _openingHours;
  final double? rating;
  final int? userRatingCount;
  final bool? isOpenNow;
  final String? photoUrl;
  final String? photoAttribution;

  List<String> get types => _types ?? const <String>[];
  List<String> get openingHours => _openingHours ?? const <String>[];
}
