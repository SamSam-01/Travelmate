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

  static const double _sheetRadius = 28;

  @override
  Widget build(BuildContext context) {
    final selectedPlace = place;
    if (selectedPlace == null) {
      return const SizedBox.shrink();
    }

    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 16, 12, 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: CrazerColors.surface,
              borderRadius: BorderRadius.circular(_sheetRadius),
              border: Border.all(color: CrazerColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_sheetRadius),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PlaceHero(place: selectedPlace, onClose: onClose),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedPlace.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: CrazerColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (_hasValue(selectedPlace.category))
                                _HeaderTag(label: selectedPlace.category!),
                              _HeaderTag(label: selectedPlace.sourceLabel),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (selectedPlace.rating != null)
                                _InfoBadge(
                                  icon: Icons.star_rounded,
                                  iconColor: CrazerColors.warmYellow,
                                  label: _buildRatingLabel(selectedPlace),
                                ),
                              if (selectedPlace.isOpenNow != null)
                                _StatusBadge(
                                  label: selectedPlace.isOpenNow!
                                      ? localizations.mapsPlaceDetailsOpen
                                      : localizations.mapsPlaceDetailsClosed,
                                  isOpen: selectedPlace.isOpenNow!,
                                ),
                            ],
                          ),
                          if (_hasValue(selectedPlace.address)) ...[
                            const SizedBox(height: 22),
                            _SectionTitle(
                              title: localizations.mapsPlaceDetailsAddress,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedPlace.address!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: CrazerColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ],
                          if (selectedPlace.openingHours.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            _SectionTitle(
                              title: localizations.mapsPlaceDetailsOpeningHours,
                            ),
                            const SizedBox(height: 10),
                            ...selectedPlace.openingHours.map(
                              (line) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  line,
                                  style: theme.textTheme.bodyMedium?.copyWith(
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  String _buildRatingLabel(SelectedMapPlace selectedPlace) {
    final baseRating = selectedPlace.rating!.toStringAsFixed(1);
    final reviewCount = selectedPlace.reviewCount;
    if (reviewCount == null) {
      return baseRating;
    }

    return '$baseRating ($reviewCount)';
  }
}

class _PlaceHero extends StatelessWidget {
  const _PlaceHero({required this.place, required this.onClose});

  final SelectedMapPlace place;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: place.photoUrl == null
              ? const _HeroFallback()
              : Image.network(
                  place.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _HeroFallback(),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return const _HeroLoading();
                  },
                ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.42),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              color: Colors.white,
            ),
          ),
        ),
        if (place.photoAttribution != null &&
            place.photoAttribution!.isNotEmpty)
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Text(
              'Photo: ${place.photoAttribution!}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ),
      ],
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CrazerColors.backgroundAlt, CrazerColors.surface],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.location_city_rounded,
          size: 52,
          color: CrazerColors.lime,
        ),
      ),
    );
  }
}

class _HeroLoading extends StatelessWidget {
  const _HeroLoading();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: CrazerColors.backgroundAlt),
      child: Center(child: CircularProgressIndicator(color: CrazerColors.lime)),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CrazerColors.backgroundAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CrazerColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: CrazerColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CrazerColors.backgroundAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: CrazerColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isOpen});

  final String label;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isOpen
        ? CrazerColors.tropicalGreen.withValues(alpha: 0.18)
        : CrazerColors.sunsetOrange.withValues(alpha: 0.18);
    final foregroundColor = isOpen
        ? CrazerColors.tropicalGreen
        : CrazerColors.sunsetOrange;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: foregroundColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: CrazerColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
