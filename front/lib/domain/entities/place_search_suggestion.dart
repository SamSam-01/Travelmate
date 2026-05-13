class PlaceSearchSuggestion {
  const PlaceSearchSuggestion({
    required this.placeId,
    required this.title,
    required this.fullText,
    this.subtitle,
  });

  final String placeId;
  final String title;
  final String fullText;
  final String? subtitle;
}
