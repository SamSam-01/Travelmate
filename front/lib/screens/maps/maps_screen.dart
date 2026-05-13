import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:front/commons.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/screens/maps/widgets/map_place_details_sheet.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

@visibleForTesting
const String mapsInteractiveStyleUri = MapboxStyles.STANDARD;

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  static const String _poiInteractionId = 'maps-poi-tap';
  static const String _placeLabelInteractionId = 'maps-place-label-tap';
  static const String _mapTapInteractionId = 'maps-map-tap';

  static final CameraOptions _initialCamera = CameraOptions(
    center: Point(coordinates: Position(55.4507, -20.8789)),
    zoom: 10,
    pitch: 20,
  );

  MapboxMap? _mapboxMap;
  String? _mapError;
  SelectedMapPlace? _selectedPlace;

  bool get _supportsNativeMap =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  void _handleMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _registerMapInteractions(mapboxMap);
  }

  void _handleMapLoadError(MapLoadingErrorEventData error) {
    if (!mounted) return;
    setState(() {
      _mapError = error.message;
    });
  }

  void _resetCamera() {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    mapboxMap.flyTo(
      _initialCamera,
      MapAnimationOptions(duration: 1800, startDelay: 0),
    );
  }

  void _registerMapInteractions(MapboxMap mapboxMap) {
    final localizations = AppLocalizations.of(context)!;

    mapboxMap.addInteraction(
      TapInteraction(
        StandardPOIs(),
        (feature, gestureContext) async {
          await _clearFeatureSelections();
          await mapboxMap.setFeatureStateForFeaturesetFeature(
            feature,
            StandardPOIsState(hide: true),
          );

          final coordinate = await mapboxMap.coordinateForPixel(
            gestureContext.touchPosition,
          );
          final placeCoordinate =
              SelectedMapPlace.coordinateFromGeometry(feature.geometry) ??
              coordinate;
          _setSelectedPlace(
            SelectedMapPlace.fromPoi(
              feature: feature,
              coordinate: placeCoordinate,
              sourceLabel: localizations.mapsPlaceDetailsSourcePoi,
            ),
          );
        },
        radius: 12,
        stopPropagation: true,
      ),
      interactionID: _poiInteractionId,
    );

    mapboxMap.addInteraction(
      TapInteraction(
        StandardPlaceLabels(),
        (feature, gestureContext) async {
          await _clearFeatureSelections();
          await mapboxMap.setFeatureStateForFeaturesetFeature(
            feature,
            StandardPlaceLabelsState(select: true),
          );

          final coordinate = await mapboxMap.coordinateForPixel(
            gestureContext.touchPosition,
          );
          _setSelectedPlace(
            SelectedMapPlace.fromPlaceLabel(
              feature: feature,
              coordinate: coordinate,
              sourceLabel: localizations.mapsPlaceDetailsSourcePlace,
            ),
          );
        },
        radius: 16,
        stopPropagation: true,
      ),
      interactionID: _placeLabelInteractionId,
    );

    mapboxMap.addInteraction(
      TapInteraction.onMap((_) {
        _clearSelection();
      }, stopPropagation: false),
      interactionID: _mapTapInteractionId,
    );
  }

  Future<void> _clearFeatureSelections() async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    try {
      await mapboxMap.resetFeatureStatesForFeatureset(StandardPOIs());
      await mapboxMap.resetFeatureStatesForFeatureset(StandardPlaceLabels());
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Mapbox feature state reset failed: $error\n$stackTrace');
    }
  }

  void _setSelectedPlace(SelectedMapPlace place) {
    if (!mounted) return;
    setState(() {
      _selectedPlace = place;
    });
  }

  Future<void> _clearSelection() async {
    await _clearFeatureSelections();
    if (!mounted) return;

    setState(() {
      _selectedPlace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (mapboxAccessToken.isEmpty) {
      return _MapsPlaceholder(
        title: localizations.mapsMissingTokenTitle,
        message: localizations.mapsMissingTokenMessage,
      );
    }

    if (!_supportsNativeMap) {
      return _MapsPlaceholder(
        title: localizations.mapsUnavailableTitle,
        message: localizations.mapsUnavailableMessage,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.mapsTitle),
        actions: [
          IconButton(
            onPressed: _resetCamera,
            icon: const Icon(Icons.my_location_outlined),
            tooltip: localizations.mapsRecenterTooltip,
          ),
        ],
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey('mapbox-map-widget'),
            // ignore: deprecated_member_use
            cameraOptions: _initialCamera,
            styleUri: mapsInteractiveStyleUri,
            onMapCreated: _handleMapCreated,
            onMapLoadErrorListener: _handleMapLoadError,
          ),
          if (_mapError != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _mapError!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CrazerColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          MapPlaceDetailsSheet(
            place: _selectedPlace,
            onClose: () {
              _clearSelection();
            },
          ),
        ],
      ),
    );
  }
}

class _MapsPlaceholder extends StatelessWidget {
  const _MapsPlaceholder({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.mapsTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 72,
                color: CrazerColors.lime,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
