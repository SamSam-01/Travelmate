import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/main.dart';
import 'package:front/screens/home/home_page.dart';
import 'package:front/screens/login/login_page.dart';
import 'package:front/styles/colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSession = supabase.auth.currentSession != null;
    final localizations = AppLocalizations.of(context)!;

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
                localizations.homeTagline,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: CrazerColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                icon: const Icon(Icons.explore_outlined),
                label: Text(
                  localizations.exploreWithoutAccount,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login_outlined),
                label: Text(
                  localizations.signIn,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (hasSession)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: Text(localizations.continueToMap),
                  style: TextButton.styleFrom(
                    foregroundColor: CrazerColors.lime,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
