import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/screens/maps/widgets/map_place_detail_components.dart';
import 'package:front/styles/colors.dart';

class MapPlaceDetailsSheet extends StatefulWidget {
  const MapPlaceDetailsSheet({
    required this.place,
    required this.onClose,
    this.onExpandedChanged,
    this.onExpansionProgressChanged,
    super.key,
  });

  final SelectedMapPlace? place;
  final VoidCallback onClose;
  final ValueChanged<bool>? onExpandedChanged;
  final ValueChanged<double>? onExpansionProgressChanged;

  @override
  State<MapPlaceDetailsSheet> createState() => _MapPlaceDetailsSheetState();
}

class _MapPlaceDetailsSheetState extends State<MapPlaceDetailsSheet> {
  static const double _collapsedSize = 0.34;
  static const double _initialSize = 0.49;
  static const double _expandedSize = 1.0;
  static const double _expandedThreshold = 0.55;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _sheetSize = _initialSize;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_handleSheetChanged);
  }

  @override
  void didUpdateWidget(covariant MapPlaceDetailsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.place == null || widget.place == oldWidget.place) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_sheetController.isAttached) {
        return;
      }

      _sheetController.animateTo(
        _initialSize,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_handleSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _handleSheetChanged() {
    if (!mounted || !_sheetController.isAttached) {
      return;
    }

    final nextSize = _sheetController.size;
    if ((nextSize - _sheetSize).abs() < 0.01) {
      return;
    }

    final nextExpanded = nextSize >= _expandedThreshold;
    if (nextExpanded != _isExpanded) {
      _isExpanded = nextExpanded;
      widget.onExpandedChanged?.call(nextExpanded);
    }

    final nextProgress =
        ((nextSize - _initialSize) / (_expandedSize - _initialSize)).clamp(
          0.0,
          1.0,
        );
    widget.onExpansionProgressChanged?.call(nextProgress);

    setState(() {
      _sheetSize = nextSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlace = widget.place;
    if (selectedPlace == null) {
      return const SizedBox.shrink();
    }

    final localizations = AppLocalizations.of(context)!;
    final detailsVisible = _sheetSize >= _expandedThreshold;
    final expansionProgress =
        ((_sheetSize - _initialSize) / (_expandedSize - _initialSize)).clamp(
          0.0,
          1.0,
        );
    final heroHeight = lerpDouble(228, 280, expansionProgress)!;
    final heroRadius = lerpDouble(20, 20, expansionProgress)!;

    return DraggableScrollableSheet(
      controller: _sheetController,
      minChildSize: _collapsedSize,
      initialChildSize: _initialSize,
      maxChildSize: _expandedSize,
      snap: true,
      snapSizes: const <double>[_initialSize, _expandedSize],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: CrazerColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(lerpDouble(28, 0, expansionProgress)!),
            ),
            boxShadow: expansionProgress > 0.95
                ? const <BoxShadow>[]
                : const <BoxShadow>[
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, -4),
                    ),
                  ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  top: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: CrazerColors.textSecondary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: heroHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(heroRadius),
                            child: MapPlaceHero(
                              place: selectedPlace,
                              aspectRatio: 16 / 9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedPlace.name,
                                    maxLines: detailsVisible ? null : 2,
                                    overflow: detailsVisible
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: CrazerColors.textPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (_hasValue(selectedPlace.category))
                                        PlaceHeaderTag(
                                          label: selectedPlace.category!,
                                        ),
                                      if (detailsVisible)
                                        PlaceHeaderTag(
                                          label: selectedPlace.sourceLabel,
                                        ),
                                      if (selectedPlace.rating != null)
                                        PlaceInfoBadge(
                                          icon: Icons.star_rounded,
                                          iconColor: CrazerColors.warmYellow,
                                          label: buildPlaceRatingLabel(
                                            selectedPlace,
                                          ),
                                        ),
                                      if (selectedPlace.isOpenNow != null)
                                        PlaceStatusBadge(
                                          label: selectedPlace.isOpenNow!
                                              ? localizations
                                                    .mapsPlaceDetailsOpen
                                              : localizations
                                                    .mapsPlaceDetailsClosed,
                                          isOpen: selectedPlace.isOpenNow!,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: widget.onClose,
                              icon: const Icon(Icons.close),
                              color: CrazerColors.textPrimary,
                            ),
                          ],
                        ),
                        if (_hasValue(selectedPlace.address)) ...[
                          const SizedBox(height: 14),
                          Text(
                            selectedPlace.address!,
                            maxLines: detailsVisible ? null : 2,
                            overflow: detailsVisible
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: CrazerColors.textSecondary,
                                  height: 1.35,
                                ),
                          ),
                        ],
                        if (detailsVisible &&
                            selectedPlace.openingHours.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          PlaceSectionTitle(
                            title: localizations.mapsPlaceDetailsOpeningHours,
                          ),
                          const SizedBox(height: 10),
                          ...selectedPlace.openingHours.map(
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
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
