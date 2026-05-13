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
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
            child: place == null
                ? _EmptyPlaceDetails(localizations: localizations)
                : Column(
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
                            tooltip: localizations.back,
                          ),
                        ],
                      ),
                      const SizedBox(height: _contentSpacing),
                      _DetailRow(
                        label: localizations.mapsPlaceDetailsLongitude,
                        value: place!.longitude.toStringAsFixed(
                          _coordinatePrecision,
                        ),
                      ),
                      _DetailRow(
                        label: localizations.mapsPlaceDetailsLatitude,
                        value: place!.latitude.toStringAsFixed(
                          _coordinatePrecision,
                        ),
                      ),
                      if (_hasValue(place!.address))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsAddress,
                          value: place!.address!,
                        ),
                      if (_hasValue(place!.placeId))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsPlaceId,
                          value: place!.placeId!,
                        ),
                      if (_hasValue(place!.category))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsCategory,
                          value: place!.category!,
                        ),
                      if (_hasValue(place!.group))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsGroup,
                          value: place!.group!,
                        ),
                      if (_hasValue(place!.icon))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsIcon,
                          value: place!.icon!,
                        ),
                      if (_hasValue(place!.transitMode))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsTransitMode,
                          value: place!.transitMode!,
                        ),
                      if (_hasValue(place!.transitStopType))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsTransitStopType,
                          value: place!.transitStopType!,
                        ),
                      if (_hasValue(place!.transitNetwork))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsTransitNetwork,
                          value: place!.transitNetwork!,
                        ),
                      if (_hasValue(place!.airportCode))
                        _DetailRow(
                          label: localizations.mapsPlaceDetailsAirportCode,
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

class _EmptyPlaceDetails extends StatelessWidget {
  const _EmptyPlaceDetails({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: MapPlaceDetailsSheet._handleWidth,
          height: MapPlaceDetailsSheet._handleHeight,
          decoration: BoxDecoration(
            color: CrazerColors.textSecondary,
            borderRadius: BorderRadius.circular(
              MapPlaceDetailsSheet._handleHeight,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Icon(Icons.place_outlined, size: 32, color: CrazerColors.lime),
        const SizedBox(height: 12),
        Text(
          localizations.mapsPlaceDetailsEmptyTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: CrazerColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.mapsPlaceDetailsEmptyMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: CrazerColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
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
