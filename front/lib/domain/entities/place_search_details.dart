class PlaceSearchDetails {
  const PlaceSearchDetails({
    required this.placeId,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.types,
  });

  final String placeId;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final List<String> types;
}
