import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HomeCarousel extends StatefulWidget {
  const HomeCarousel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    this.viewportFraction = 0.88,
    this.height = 210,
  });

  final String title;
  final String subtitle;
  final List<HomeCarouselItem> items;
  final double viewportFraction;
  final double height;

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.viewportFraction,
  );

  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: widget.title, subtitle: widget.subtitle),
        const SizedBox(height: 12),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Reserve space for the indicator + spacing explicitly to avoid
              // RenderFlex overflow when the parent has tight constraints.
              const indicatorHeight = 8.0;
              const indicatorSpacing = 12.0;
              final pageViewHeight =
                  (constraints.maxHeight - indicatorHeight - indicatorSpacing)
                      .clamp(0.0, constraints.maxHeight);

              return Column(
                children: [
                  SizedBox(
                    height: pageViewHeight,
                    child: ScrollConfiguration(
                      behavior: const _CarouselScrollBehavior(),
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: widget.items.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          return AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: index == _currentIndex ? 1 : 0.97,
                            child: _CarouselCard(item: item),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: indicatorSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: indicatorHeight,
                        width: _currentIndex == index ? 22 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class HomeCarouselItem {
  const HomeCarouselItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final HomeCarouselTone tone;
}

enum HomeCarouselTone {
  nature,
  city,
  food,
  culture,
  planned,
  hiking,
  dinner,
  water,
}

class _CarouselScrollBehavior extends MaterialScrollBehavior {
  const _CarouselScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    ...super.dragDevices,
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.item});

  final HomeCarouselItem item;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveGradient(context, item.tone);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: scheme.onPrimary),
                ),
                const Spacer(),
                _Badge(label: item.badge),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _resolveGradient(BuildContext context, HomeCarouselTone tone) {
    final scheme = Theme.of(context).colorScheme;

    return switch (tone) {
      HomeCarouselTone.nature => [
        scheme.primaryContainer,
        scheme.secondaryContainer,
      ],
      HomeCarouselTone.city => [
        scheme.secondaryContainer,
        scheme.tertiaryContainer,
      ],
      HomeCarouselTone.food => [
        scheme.tertiaryContainer,
        scheme.primaryContainer,
      ],
      HomeCarouselTone.culture => [
        scheme.surfaceContainerHighest,
        scheme.primaryContainer,
      ],
      HomeCarouselTone.planned => [scheme.secondary, scheme.primary],
      HomeCarouselTone.hiking => [scheme.primary, scheme.tertiary],
      HomeCarouselTone.dinner => [scheme.error, scheme.secondary],
      HomeCarouselTone.water => [scheme.tertiary, scheme.primaryContainer],
    };
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
