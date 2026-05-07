import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/screens/app/authenticated_app_shell.dart';
import 'package:front/screens.dart';
import 'package:front/theme/crazer_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.hasSessionOverride});

  final bool? hasSessionOverride;

  @override
  Widget build(BuildContext context) {
    final hasSession =
        hasSessionOverride ?? supabase.auth.currentSession != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/Crazer_LOGO.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'CRAZER',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CrazerColors.lime,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Votre compagnon de voyage idéal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: CrazerColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité d\'exploration à venir !'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Explorer sans compte',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Screens.login);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (hasSession)
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(Screens.app, arguments: AppShellTab.profile);
                  },
                  child: Text(
                    'Accéder à mon compte',
                    style: TextStyle(
                      color: CrazerColors.lime,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
