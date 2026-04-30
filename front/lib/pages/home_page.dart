import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/pages/account_page.dart';
import 'package:front/pages/login_page.dart';
import 'package:front/pages/welcome_page.dart';
import 'package:front/theme/crazer_theme.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final _parisCenter = Point(coordinates: Position(2.3522, 48.8566));

  static final _initialCamera = CameraOptions(
    center: _parisCenter,
    zoom: 11.8,
    bearing: -16,
    pitch: 48,
  );

  MapboxMap? _mapboxMap;
  bool _useSatellite = false;

  bool get _isConnected => supabase.auth.currentSession != null;

  String get _styleUri =>
      _useSatellite ? MapboxStyles.STANDARD_SATELLITE : MapboxStyles.STANDARD;

  void _handleMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
  }

  Future<void> _resetCamera() async {
    await _mapboxMap?.flyTo(
      _initialCamera,
      MapAnimationOptions(duration: 900, startDelay: 0),
    );
  }

  void _toggleStyle() {
    setState(() {
      _useSatellite = !_useSatellite;
    });
  }

  void _openAccountOrLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _isConnected ? const AccountPage() : const LoginPage(),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {
      if (!mounted) return;
      context.showSnackBar('Erreur pendant la déconnexion', isError: true);
      return;
    }

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomePage()));
  }

  @override
  Widget build(BuildContext context) {
    final hasMapboxToken = mapboxAccessToken.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: hasMapboxToken
                ? MapWidget(
                    key: ValueKey(_styleUri),
                    styleUri: _styleUri,
                    viewport: CameraViewportState(
                      center: _parisCenter,
                      zoom: 11.8,
                      bearing: -16,
                      pitch: 48,
                    ),
                    onMapCreated: _handleMapCreated,
                  )
                : const _MissingMapboxToken(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TopMapBar(
                    isConnected: _isConnected,
                    onBack: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                      );
                    },
                    onAccountPressed: _openAccountOrLogin,
                    onSignOutPressed: _isConnected ? _signOut : null,
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _MapControls(
                      useSatellite: _useSatellite,
                      onStylePressed: hasMapboxToken ? _toggleStyle : null,
                      onResetPressed: hasMapboxToken ? _resetCamera : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopMapBar extends StatelessWidget {
  const _TopMapBar({
    required this.isConnected,
    required this.onBack,
    required this.onAccountPressed,
    required this.onSignOutPressed,
  });

  final bool isConnected;
  final VoidCallback onBack;
  final VoidCallback onAccountPressed;
  final VoidCallback? onSignOutPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MapIconButton(
          tooltip: 'Accueil',
          icon: Icons.arrow_back,
          onPressed: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: CrazerColors.background.withValues(alpha: 0.82),
              border: Border.all(color: CrazerColors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Image.asset(
                  'lib/assets/Crazer_LOGO.png',
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Text(
                  'CRAZER',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CrazerColors.lime,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  isConnected ? 'Connecté' : 'Invité',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CrazerColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _MapIconButton(
          tooltip: isConnected ? 'Compte' : 'Connexion',
          icon: isConnected ? Icons.person_outline : Icons.login_outlined,
          onPressed: onAccountPressed,
        ),
        if (onSignOutPressed != null) ...[
          const SizedBox(width: 8),
          _MapIconButton(
            tooltip: 'Déconnexion',
            icon: Icons.logout_outlined,
            onPressed: onSignOutPressed,
          ),
        ],
      ],
    );
  }
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.useSatellite,
    required this.onStylePressed,
    required this.onResetPressed,
  });

  final bool useSatellite;
  final VoidCallback? onStylePressed;
  final VoidCallback? onResetPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapIconButton(
          tooltip: useSatellite ? 'Vue standard' : 'Vue satellite',
          icon: useSatellite ? Icons.map_outlined : Icons.satellite_alt,
          onPressed: onStylePressed,
        ),
        const SizedBox(height: 10),
        _MapIconButton(
          tooltip: 'Recentrer',
          icon: Icons.center_focus_strong,
          onPressed: onResetPressed,
        ),
      ],
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CrazerColors.background.withValues(alpha: 0.82),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: CrazerColors.border),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        color: CrazerColors.textPrimary,
        disabledColor: CrazerColors.textSecondary,
      ),
    );
  }
}

class _MissingMapboxToken extends StatelessWidget {
  const _MissingMapboxToken();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CrazerColors.background,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 56,
                color: CrazerColors.lime,
              ),
              const SizedBox(height: 20),
              Text(
                'Token Mapbox manquant',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Ajoutez MAPBOX_ACCESS_TOKEN dans front/.env puis relancez l\'app avec les dart-define.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
