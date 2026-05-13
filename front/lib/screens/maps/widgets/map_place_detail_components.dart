import 'package:flutter/material.dart';
import 'package:front/screens/maps/models/selected_map_place.dart';
import 'package:front/styles/colors.dart';

String buildPlaceRatingLabel(SelectedMapPlace place) {
  final rating = place.rating;
  if (rating == null) {
    return '';
  }

  final baseRating = rating.toStringAsFixed(1);
  final reviewCount = place.reviewCount;
  if (reviewCount == null) {
    return baseRating;
  }

  return '$baseRating ($reviewCount)';
}

class MapPlaceHero extends StatelessWidget {
  const MapPlaceHero({
    required this.place,
    this.aspectRatio = 16 / 9,
    this.onClose,
    super.key,
  });

  final SelectedMapPlace place;
  final double aspectRatio;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: place.photoUrl == null
              ? const _HeroFallback()
              : Image.network(
                  place.photoUrl!,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
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
                  Colors.black.withValues(alpha: 0.12),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        if (onClose != null)
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

class PlaceHeaderTag extends StatelessWidget {
  const PlaceHeaderTag({required this.label, super.key});

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

class PlaceInfoBadge extends StatelessWidget {
  const PlaceInfoBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
    super.key,
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

class PlaceStatusBadge extends StatelessWidget {
  const PlaceStatusBadge({
    required this.label,
    required this.isOpen,
    super.key,
  });

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

class PlaceSectionTitle extends StatelessWidget {
  const PlaceSectionTitle({required this.title, super.key});

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
