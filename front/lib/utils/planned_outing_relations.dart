import 'package:front/models/planned_outing_model.dart';

List<PlannedOuting> buildPlannedOutingsFromRelations({
  required List<Map<String, dynamic>> outingRows,
  required Map<String, List<PlannedOutingUser>> usersByOutingId,
  required Map<String, List<PlannedOutingActivity>> activitiesByOutingId,
  String? currentUserId,
}) {
  final normalizedUserId = currentUserId?.trim() ?? '';

  final outings = outingRows
      .map(
        (row) => PlannedOuting(
          id: (row['id'] ?? '').toString(),
          title: (row['title'] ?? '').toString(),
          users:
              usersByOutingId[(row['id'] ?? '').toString()] ??
              const <PlannedOutingUser>[],
          activities:
              activitiesByOutingId[(row['id'] ?? '').toString()] ??
              const <PlannedOutingActivity>[],
          createdAt: DateTime.tryParse((row['created_at'] ?? '').toString()),
        ),
      )
      .where((outing) => outing.id.isNotEmpty && outing.title.isNotEmpty)
      .toList(growable: false);

  if (normalizedUserId.isEmpty) {
    return const <PlannedOuting>[];
  }

  return outings
      .where((outing) => outing.includesUserId(normalizedUserId))
      .toList(growable: false);
}
