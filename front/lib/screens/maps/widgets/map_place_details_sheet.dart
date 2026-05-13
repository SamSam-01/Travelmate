import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/screens/maps/widgets/map_place_detail_components.dart';
import 'package:front/styles/colors.dart';

class MapPlaceDetailsSheet extends StatelessWidget {
  const MapPlaceDetailsSheet({
    required this.place,
    required this.onClose,
    required this.onExpand,
    super.key,
  });

  final SelectedMapPlace? place;
  final VoidCallback onClose;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final selectedPlace = place;
    if (selectedPlace == null) {
      return const SizedBox.shrink();
    }

    final localizations = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < -250) {
              onExpand();
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              color: CrazerColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CrazerColors.textSecondary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 92,
                          height: 92,
                          child: MapPlaceHero(
                            place: selectedPlace,
                            aspectRatio: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPlace.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: CrazerColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (_hasValue(selectedPlace.category))
                                  PlaceHeaderTag(
                                    label: selectedPlace.category!,
                                  ),
                                if (selectedPlace.rating != null)
                                  PlaceInfoBadge(
                                    icon: Icons.star_rounded,
                                    iconColor: CrazerColors.warmYellow,
                                    label: buildPlaceRatingLabel(selectedPlace),
                                  ),
                                if (selectedPlace.isOpenNow != null)
                                  PlaceStatusBadge(
                                    label: selectedPlace.isOpenNow!
                                        ? localizations.mapsPlaceDetailsOpen
                                        : localizations.mapsPlaceDetailsClosed,
                                    isOpen: selectedPlace.isOpenNow!,
                                  ),
                              ],
                            ),
                            if (_hasValue(selectedPlace.address)) ...[
                              const SizedBox(height: 10),
                              Text(
                                selectedPlace.address!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: CrazerColors.textSecondary,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        color: CrazerColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: onExpand,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: CrazerColors.lime,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            localizations.mapsPlaceDetailsMoreDetails,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: CrazerColors.lime,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
