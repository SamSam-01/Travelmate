import 'dart:async';

import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/screens/account/account_page.dart';
import 'package:front/theme/crazer_theme.dart';
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AccountPage()),
    );
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 48),
              const _CrazerLoginHeader(),
              const SizedBox(height: 48),
              _LoginFormFields(
                emailController: _emailController,
                passwordController: _passwordController,
                emailFocusNode: _emailFocusNode,
                passwordFocusNode: _passwordFocusNode,
                onSubmitted: _submit,
              ),
              const SizedBox(height: 32),
              _LoginPrimaryButton(
                isLoading: _isLoading,
                isSignUp: _isSignUp,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              _LoginModeToggle(
                isLoading: _isLoading,
                isSignUp: _isSignUp,
                onPressed: _toggleMode,
              ),
              const SizedBox(height: 32),
              _BackHomeButton(isLoading: _isLoading),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrazerLoginHeader extends StatelessWidget {
  const _CrazerLoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/Crazer_LOGO.png',
          height: 96,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Text(
          'CRAZER',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: CrazerColors.lime,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginFormFields extends StatelessWidget {
  const _LoginFormFields({
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onSubmitted,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 16),
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
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(
        isSignUp
            ? 'Déjà un compte ? Se connecter'
            : 'Pas de compte ? Créer un compte',
        style: const TextStyle(
          color: CrazerColors.lime,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
      icon: const Icon(Icons.home_outlined),
      label: const Text('Retour à l\'accueil'),
      style: TextButton.styleFrom(foregroundColor: CrazerColors.textSecondary),
    );
  }
}
