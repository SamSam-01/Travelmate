import 'package:front/domain/entities/place_search_suggestion.dart';

class PlaceSearchSuggestionModel extends PlaceSearchSuggestion {
  const PlaceSearchSuggestionModel({
    required super.placeId,
    required super.title,
    required super.fullText,
    super.subtitle,
  });

  factory PlaceSearchSuggestionModel.fromJson(Map<String, Object?> json) {
    final structuredFormat =
        json['structuredFormat'] as Map<Object?, Object?>? ?? const {};
    final mainText =
        structuredFormat['mainText'] as Map<Object?, Object?>? ?? const {};
    final secondaryText =
        structuredFormat['secondaryText'] as Map<Object?, Object?>? ?? const {};
    final text = json['text'] as Map<Object?, Object?>? ?? const {};

    final title =
        (mainText['text'] as String?) ?? (text['text'] as String?) ?? '';
    final subtitle = secondaryText['text'] as String?;

    return PlaceSearchSuggestionModel(
      placeId: json['placeId'] as String? ?? '',
      title: title,
      subtitle: subtitle,
      fullText: text['text'] as String? ?? title,
    );
  }
}
