import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/models/place_search_suggestion_model.dart';

void main() {
  test('should map structured autocomplete response to suggestion model', () {
    final suggestion = PlaceSearchSuggestionModel.fromJson(<String, Object?>{
      'placeId': 'abc123',
      'text': <String, Object?>{'text': 'Louvre Museum, Paris, France'},
      'structuredFormat': <String, Object?>{
        'mainText': <String, Object?>{'text': 'Louvre Museum'},
        'secondaryText': <String, Object?>{'text': 'Paris, France'},
      },
    });

    expect(suggestion.placeId, 'abc123');
    expect(suggestion.title, 'Louvre Museum');
    expect(suggestion.subtitle, 'Paris, France');
    expect(suggestion.fullText, 'Louvre Museum, Paris, France');
  });
}
