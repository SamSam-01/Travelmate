import 'package:front/models/activity_model.dart';
import 'package:front/models/planned_outing_model.dart';
import 'package:front/widgets/home_carousel.dart';

List<PlannedOuting> filterPlannedOutingsForUser({
  required List<PlannedOuting> plannedOutings,
  required String? userId,
}) {
  final normalizedUserId = userId?.trim() ?? '';
  if (normalizedUserId.isEmpty) {
    return const <PlannedOuting>[];
  }

  return plannedOutings
      .where((outing) => outing.includesUserId(normalizedUserId))
      .toList(growable: false);
}

List<HomeCarouselItem> resolvePlannedOutingCarouselItems({
  required List<PlannedOuting> plannedOutings,
  required List<Activity> activities,
  String? userId,
}) {
  final visiblePlannedOutings = filterPlannedOutingsForUser(
    plannedOutings: plannedOutings,
    userId: userId,
  );

  if (visiblePlannedOutings.isNotEmpty) {
    return visiblePlannedOutings
        .map((outing) => outing.toCarouselItem())
        .toList(growable: false);
  }

  return activities
      .where((activity) => activity.tone == HomeCarouselTone.planned)
      .map((activity) => activity.toCarouselItem())
      .toList(growable: false);
}
