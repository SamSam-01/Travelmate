import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/screens/maps/widgets/map_place_detail_components.dart';
import 'package:front/styles/colors.dart';

class MapPlaceDetailsPage extends StatefulWidget {
  const MapPlaceDetailsPage({required this.place, super.key});

  final SelectedMapPlace place;

  @override
  State<MapPlaceDetailsPage> createState() => _MapPlaceDetailsPageState();
}

class _MapPlaceDetailsPageState extends State<MapPlaceDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  double _dragOffset = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isAtTop =>
      !_scrollController.hasClients || _scrollController.offset <= 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final place = widget.place;

    return Scaffold(
      backgroundColor: CrazerColors.surface,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (_isAtTop && details.delta.dy > 0) {
            _dragOffset += details.delta.dy;
          }
        },
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (_isAtTop && (_dragOffset > 90 || velocity > 900)) {
            Navigator.of(context).maybePop();
          }

          _dragOffset = 0;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: CrazerColors.surface,
              expandedHeight: 320,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: MapPlaceHero(
                  place: place,
                  onClose: () {
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: CrazerColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_hasValue(place.category))
                          PlaceHeaderTag(label: place.category!),
                        PlaceHeaderTag(label: place.sourceLabel),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (place.rating != null)
                          PlaceInfoBadge(
                            icon: Icons.star_rounded,
                            iconColor: CrazerColors.warmYellow,
                            label: buildPlaceRatingLabel(place),
                          ),
                        if (place.isOpenNow != null)
                          PlaceStatusBadge(
                            label: place.isOpenNow!
                                ? localizations.mapsPlaceDetailsOpen
                                : localizations.mapsPlaceDetailsClosed,
                            isOpen: place.isOpenNow!,
                          ),
                      ],
                    ),
                    if (_hasValue(place.address)) ...[
                      const SizedBox(height: 24),
                      PlaceSectionTitle(
                        title: localizations.mapsPlaceDetailsAddress,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.address!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: CrazerColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (place.openingHours.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      PlaceSectionTitle(
                        title: localizations.mapsPlaceDetailsOpeningHours,
                      ),
                      const SizedBox(height: 10),
                      ...place.openingHours.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            line,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: CrazerColors.textSecondary,
                                  height: 1.3,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
