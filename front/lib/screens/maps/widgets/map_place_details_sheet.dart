import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/styles/colors.dart';

class MapPlaceDetailsSheet extends StatelessWidget {
  const MapPlaceDetailsSheet({
    required this.place,
    required this.onClose,
    super.key,
  });

  final SelectedMapPlace? place;
  final VoidCallback onClose;

  static const double _sheetRadius = 24;
  static const double _handleWidth = 40;
  static const double _handleHeight = 4;
  static const double _sheetBottomPadding = 32;
  static const double _contentSpacing = 12;
  static const double _sectionSpacing = 16;
  static const int _coordinatePrecision = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (place == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 16, 16, _sheetBottomPadding),
        child: Container(
          decoration: BoxDecoration(
            color: CrazerColors.surface,
            borderRadius: BorderRadius.circular(_sheetRadius),
            border: Border.all(color: CrazerColors.border),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: _handleWidth,
                    height: _handleHeight,
                    decoration: BoxDecoration(
                      color: CrazerColors.textSecondary,
                      borderRadius: BorderRadius.circular(_handleHeight),
                    ),
                  ),
                ),
                const SizedBox(height: _sectionSpacing),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place!.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: CrazerColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place!.sourceLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: CrazerColors.lime,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      color: CrazerColors.textPrimary,
                      tooltip: AppLocalizations.of(context)!.back,
                    ),
                  ],
                ),
                const SizedBox(height: _contentSpacing),
                _DetailRow(
                  label: AppLocalizations.of(
                    context,
                  )!.mapsPlaceDetailsLongitude,
                  value: place!.longitude.toStringAsFixed(_coordinatePrecision),
                ),
                _DetailRow(
                  label: AppLocalizations.of(context)!.mapsPlaceDetailsLatitude,
                  value: place!.latitude.toStringAsFixed(_coordinatePrecision),
                ),
                if (place!.rating != null)
                  _DetailRow(
                    label: AppLocalizations.of(context)!.mapsPlaceDetailsRating,
                    value: place!.rating!.toStringAsFixed(1),
                  ),
                if (place!.reviewCount != null)
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsReviewCount,
                    value: place!.reviewCount.toString(),
                  ),
                if (place!.isOpenNow != null)
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsOpenNow,
                    value: place!.isOpenNow!
                        ? AppLocalizations.of(context)!.mapsPlaceDetailsOpen
                        : AppLocalizations.of(context)!.mapsPlaceDetailsClosed,
                  ),
                if (_hasValue(place!.address))
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsAddress,
                    value: place!.address!,
                  ),
                if (_hasValue(place!.placeId))
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsPlaceId,
                    value: place!.placeId!,
                  ),
                if (_hasValue(place!.category))
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsCategory,
                    value: place!.category!,
                  ),
                if (_hasValue(place!.group))
                  _DetailRow(
                    label: AppLocalizations.of(context)!.mapsPlaceDetailsGroup,
                    value: place!.group!,
                  ),
                if (_hasValue(place!.icon))
                  _DetailRow(
                    label: AppLocalizations.of(context)!.mapsPlaceDetailsIcon,
                    value: place!.icon!,
                  ),
                if (_hasValue(place!.transitMode))
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsTransitMode,
                    value: place!.transitMode!,
                  ),
                if (_hasValue(place!.transitStopType))
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsTransitStopType,
                    value: place!.transitStopType!,
                  ),
                if (_hasValue(place!.transitNetwork))
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsTransitNetwork,
                    value: place!.transitNetwork!,
                  ),
                if (_hasValue(place!.airportCode))
                  _DetailRow(
                    label: AppLocalizations.of(
                      context,
                    )!.mapsPlaceDetailsAirportCode,
                    value: place!.airportCode!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: CrazerColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: CrazerColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
