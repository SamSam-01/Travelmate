import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:front/commons.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/theme/crazer_theme.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  static final CameraOptions _initialCamera = CameraOptions(
    center: Point(coordinates: Position(55.4507, -20.8789)),
    zoom: 10,
    pitch: 20,
  );

  MapboxMap? _mapboxMap;
  String? _mapError;

  bool get _supportsNativeMap =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  void _handleMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
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
            styleUri: MapboxStyles.MAPBOX_STREETS,
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
