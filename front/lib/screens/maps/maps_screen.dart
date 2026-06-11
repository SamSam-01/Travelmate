import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:front/commons.dart';
import 'package:front/data/datasources/google_places_remote_data_source.dart';
import 'package:front/data/repositories/place_search_repository_impl.dart';
import 'package:front/domain/entities/place_search_suggestion.dart';
import 'package:front/domain/repositories/place_search_repository.dart';
import 'package:front/domain/usecases/get_place_details_use_case.dart';
import 'package:front/domain/usecases/search_place_suggestions_use_case.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/screens/maps/widgets/map_place_details_sheet.dart';
import 'package:front/screens/maps/widgets/map_place_search_panel.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

@visibleForTesting
const String mapsInteractiveStyleUri = MapboxStyles.STANDARD;

class MapsScreen extends StatefulWidget {
  const MapsScreen({
    super.key,
    this.outingMode = false,
    this.addToOutingLabel,
    this.onConfirmPlaces,
    this.initialPlaces,
  });

  final bool outingMode;
  final String? addToOutingLabel;
  final ValueChanged<List<SelectedMapPlace>>? onConfirmPlaces;
  final List<SelectedMapPlace>? initialPlaces;

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  static const int _minimumSearchLength = 2;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 350);
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
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<PlaceSearchSuggestion> _suggestions = const [];
  bool _isSearching = false;
  bool _isLoadingPlaceDetails = false;
  bool _isPlaceDetailsExpanded = false;
  double _sheetExpansionProgress = 0;
  String? _searchError;
  String? _searchSessionToken;
  int _searchVersion = 0;
  bool _ignoreSearchChange = false;
  final List<SelectedMapPlace> _pickedPlaces = [];

  late final PlaceSearchRepository? _placeSearchRepository =
      googlePlacesApiKey.isEmpty
      ? null
      : PlaceSearchRepositoryImpl(
          GooglePlacesRemoteDataSource(googlePlacesApiKey),
        );
  late final SearchPlaceSuggestionsUseCase? _searchPlaceSuggestionsUseCase =
      _placeSearchRepository == null
      ? null
      : SearchPlaceSuggestionsUseCase(_placeSearchRepository);
  late final GetPlaceDetailsUseCase? _getPlaceDetailsUseCase =
      _placeSearchRepository == null
      ? null
      : GetPlaceDetailsUseCase(_placeSearchRepository);

  bool get _supportsNativeMap =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  bool get _isPlaceSearchEnabled => _searchPlaceSuggestionsUseCase != null;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    if (widget.initialPlaces != null) {
      _pickedPlaces.addAll(widget.initialPlaces!);
    }
  }

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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _resetCamera() {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    mapboxMap.flyTo(
      _initialCamera,
      MapAnimationOptions(duration: 1800, startDelay: 0),
    );
  }

  void _onSearchChanged() {
    if (_ignoreSearchChange) {
      _ignoreSearchChange = false;
      return;
    }

    final query = _searchController.text.trim();
    _searchDebounce?.cancel();

    if (!_isPlaceSearchEnabled || query.length < _minimumSearchLength) {
      _searchSessionToken = null;
      setState(() {
        _suggestions = const [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(_searchDebounceDelay, () {
      _searchGooglePlaces(query);
    });
  }

  Future<void> _searchGooglePlaces(String query) async {
    final useCase = _searchPlaceSuggestionsUseCase;
    if (useCase == null) return;

    final requestVersion = ++_searchVersion;
    _searchSessionToken ??= _buildSessionToken();

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    final result = await useCase(
      query,
      sessionToken: _searchSessionToken!,
      languageCode: Localizations.localeOf(context).languageCode,
      regionCode: 'FR',
    );

    if (!mounted || requestVersion != _searchVersion) return;

    result.match(
      (failure) {
        setState(() {
          _isSearching = false;
          _suggestions = const [];
          _searchError = failure.message;
        });
      },
      (suggestions) {
        setState(() {
          _isSearching = false;
          _suggestions = suggestions;
          _searchError = null;
        });
      },
    );
  }

  Future<void> _selectSuggestion(PlaceSearchSuggestion suggestion) async {
    final useCase = _getPlaceDetailsUseCase;
    final mapboxMap = _mapboxMap;
    if (useCase == null || mapboxMap == null) return;

    setState(() {
      _isLoadingPlaceDetails = true;
      _searchError = null;
      _suggestions = const [];
    });

    final result = await useCase(
      suggestion.placeId,
      sessionToken: _searchSessionToken,
      languageCode: Localizations.localeOf(context).languageCode,
      regionCode: 'FR',
    );

    if (!mounted) return;

    result.match(
      (failure) {
        setState(() {
          _isLoadingPlaceDetails = false;
          _searchError = failure.message;
        });
      },
      (details) {
        final place = SelectedMapPlace.fromGooglePlace(
          suggestion: suggestion,
          details: details,
          sourceLabel: AppLocalizations.of(
            context,
          )!.mapsPlaceDetailsSourceGoogle,
        );

        _searchSessionToken = null;
        _ignoreSearchChange = true;
        _searchController.text = suggestion.fullText;

        setState(() {
          _isLoadingPlaceDetails = false;
          _selectedPlace = place;
        });

        mapboxMap.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(place.longitude, place.latitude),
            ),
            zoom: 14,
            pitch: 20,
          ),
          MapAnimationOptions(duration: 1400, startDelay: 0),
        );
      },
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchSessionToken = null;
    _searchController.clear();
    setState(() {
      _suggestions = const [];
      _searchError = null;
      _isSearching = false;
      _isLoadingPlaceDetails = false;
    });
  }

  String _buildSessionToken() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_searchVersion + 1}';

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

  void _addPlaceToOuting() {
    final place = _selectedPlace;
    if (place == null) return;

    final alreadyAdded = _pickedPlaces.any(
      (p) =>
          p.name == place.name &&
          (p.latitude - place.latitude).abs() < 0.0001 &&
          (p.longitude - place.longitude).abs() < 0.0001,
    );
    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${place.name} est déjà dans la sortie.'),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        ),
      );
      return;
    }

    setState(() {
      _pickedPlaces.add(place);
    });
  }

  void _removePickedPlace(int index) {
    setState(() {
      _pickedPlaces.removeAt(index);
    });
  }

  void _confirmPickedPlaces() {
    widget.onConfirmPlaces?.call(List<SelectedMapPlace>.from(_pickedPlaces));
  }

  Future<void> _clearSelection() async {
    await _clearFeatureSelections();
    if (!mounted) return;

    setState(() {
      _selectedPlace = null;
      _isPlaceDetailsExpanded = false;
      _sheetExpansionProgress = 0;
    });
  }

  double get _searchOverlayOpacity => 1 - _sheetExpansionProgress.clamp(0, 1);

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
          if (widget.outingMode && _pickedPlaces.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: CrazerColors.lime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: _confirmPickedPlaces,
                icon: const Icon(Icons.check, size: 20),
                label: Text(
                  'Confirmer (${_pickedPlaces.length})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
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
          if (widget.outingMode && _pickedPlaces.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PickedPlacesBar(
                places: _pickedPlaces,
                onRemove: _removePickedPlace,
              ),
            ),
          MapPlaceDetailsSheet(
            place: _selectedPlace,
            onClose: () {
              _clearSelection();
            },
            onAddToOuting: widget.outingMode ? _addPlaceToOuting : null,
            addToOutingLabel: widget.addToOutingLabel,
            onExpandedChanged: (isExpanded) {
              if (!mounted || _isPlaceDetailsExpanded == isExpanded) {
                return;
              }

              setState(() {
                _isPlaceDetailsExpanded = isExpanded;
              });
            },
            onExpansionProgressChanged: (progress) {
              if (!mounted ||
                  (_sheetExpansionProgress - progress).abs() < 0.01) {
                return;
              }

              setState(() {
                _sheetExpansionProgress = progress;
              });
            },
          ),
          IgnorePointer(
            ignoring: _isPlaceDetailsExpanded,
            child: Opacity(
              opacity: _searchOverlayOpacity,
              child: MapPlaceSearchPanel(
                controller: _searchController,
                onClear: _clearSearch,
                onSuggestionSelected: _selectSuggestion,
                suggestions: _suggestions,
                isEnabled: _isPlaceSearchEnabled,
                isLoading: _isSearching || _isLoadingPlaceDetails,
                errorMessage: _searchError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@visibleForTesting
class PickedPlacesBar extends StatelessWidget {
  const PickedPlacesBar({
    required this.places,
    required this.onRemove,
    super.key,
  });

  final List<SelectedMapPlace> places;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Card(
          color: CrazerColors.surface.withValues(alpha: 0.95),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: List.generate(places.length, (index) {
                final place = places[index];
                return Chip(
                  avatar: const Icon(Icons.place, size: 18),
                  label: Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => onRemove(index),
                  backgroundColor: CrazerColors.lime.withValues(alpha: 0.2),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ),
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
