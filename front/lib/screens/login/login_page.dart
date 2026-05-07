import 'dart:async';

import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/screens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final StreamSubscription<AuthState> _authStateSubscription;

  bool _isLoading = false;
  bool _redirecting = false;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      _handleAuthStateChange,
      onError: _handleAuthError,
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final response = _isSignUp
          ? await supabase.auth.signUp(email: email, password: password)
          : await supabase.auth.signInWithPassword(
              email: email,
              password: password,
            );

      if (!mounted) return;
      if (response.session != null) {
        context.showSnackBar(
          _isSignUp ? 'Compte créé avec succès !' : 'Connexion réussie !',
        );
      } else if (_isSignUp) {
        context.showSnackBar(
          'Vérifiez votre email pour confirmer votre compte',
        );
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (_) {
      if (mounted) context.showSnackBar('Erreur inattendue', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return false;
    FocusManager.instance.primaryFocus?.unfocus();
    return true;
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  void _handleAuthStateChange(AuthState data) {
    if (!mounted || _redirecting || data.session == null) return;

    _redirecting = true;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(Screens.app, (_) => false);
  }

  void _handleAuthError(Object error) {
    if (!mounted) return;

    final message = error is AuthException
        ? error.message
        : 'Erreur inattendue';
    context.showSnackBar(message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isSignUp ? 'Créer un compte' : 'Se connecter';
    final subtitle = _isSignUp
        ? 'Crée ton espace pour retrouver tes voyages.'
        : 'Connecte-toi pour accéder à ton espace.';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              colorScheme.surface,
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 700;

                  return Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: constraints.maxWidth > 420
                            ? 420
                            : constraints.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _LoginTopBar(),
                            SizedBox(height: isCompact ? 8 : 20),
                            _CrazerLoginHeader(
                              title: title,
                              subtitle: subtitle,
                              isCompact: isCompact,
                            ),
                            SizedBox(height: isCompact ? 18 : 28),
                            _LoginFormCard(
                              isLoading: _isLoading,
                              isSignUp: _isSignUp,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              emailFocusNode: _emailFocusNode,
                              passwordFocusNode: _passwordFocusNode,
                              onSubmitted: _submit,
                              onToggleMode: _toggleMode,
                              isCompact: isCompact,
                            ),
                            SizedBox(height: isCompact ? 8 : 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrazerLoginHeader extends StatelessWidget {
  const _CrazerLoginHeader({
    required this.title,
    required this.subtitle,
    required this.isCompact,
  });

  final String title;
  final String subtitle;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SizedBox(
          width: isCompact ? 210 : 300,
          height: isCompact ? 150 : 220,
          child: Image.asset(
            'assets/images/Crazer_LOGO.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: isCompact ? 0 : 4),
        Text(
          'CRAZER',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isCompact ? 10 : 18),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isCompact ? 6 : 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
      ],
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.isLoading,
    required this.isSignUp,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onSubmitted,
    required this.onToggleMode,
    required this.isCompact,
  });

  final bool isLoading;
  final bool isSignUp;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onSubmitted;
  final VoidCallback onToggleMode;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: emailController,
          focusNode: emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: _validateEmail,
          onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
        ),
        SizedBox(height: isCompact ? 12 : 16),
        TextFormField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: Icon(Icons.lock_outlined),
          ),
          validator: _validatePassword,
          onFieldSubmitted: (_) => onSubmitted(),
        ),
        SizedBox(height: isCompact ? 18 : 24),
        _LoginPrimaryButton(
          isLoading: isLoading,
          isSignUp: isSignUp,
          onPressed: onSubmitted,
        ),
        SizedBox(height: isCompact ? 10 : 14),
        _LoginModeToggle(
          isLoading: isLoading,
          isSignUp: isSignUp,
          onPressed: onToggleMode,
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Renseignez votre email';
    if (!email.contains('@')) return 'Email invalide';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Renseignez votre mot de passe';
    if (password.length < 6) return '6 caracteres minimum';
    return null;
  }
}

class _LoginPrimaryButton extends StatelessWidget {
  const _LoginPrimaryButton({
    required this.isLoading,
    required this.isSignUp,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isSignUp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                isSignUp ? 'Créer un compte' : 'Se connecter',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _LoginModeToggle extends StatelessWidget {
  const _LoginModeToggle({
    required this.isLoading,
    required this.isSignUp,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isSignUp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(
        isSignUp
            ? 'Déjà un compte ? Se connecter'
            : 'Pas de compte ? Créer un compte',
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
