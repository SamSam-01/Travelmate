import 'dart:async';

import 'package:flutter/material.dart';
import 'package:front/l10n/app_localizations.dart';
import 'package:front/main.dart';
import 'package:front/screens.dart';
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
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
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
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _usernameController.dispose();
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
      final username = _usernameController.text.trim().toLowerCase();
      final password = _passwordController.text.trim();
      final response = _isSignUp
          ? await supabase.auth.signUp(
              email: email,
              password: password,
              data: <String, dynamic>{
                'username': username,
                'display_name': username,
              },
            )
          : await supabase.auth.signInWithPassword(
              email: email,
              password: password,
            );

      if (!mounted) return;
      final localizations = AppLocalizations.of(context)!;
      if (response.session != null) {
        context.showSnackBar(
          _isSignUp
              ? localizations.loginSignUpSuccess
              : localizations.loginSignInSuccess,
        );
      } else if (_isSignUp) {
        context.showSnackBar(localizations.loginCheckEmail);
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        context.showSnackBar(
          AppLocalizations.of(context)!.loginUnexpectedError,
          isError: true,
        );
      }
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
        : AppLocalizations.of(context)!.loginUnexpectedError;
    context.showSnackBar(message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final title = _isSignUp
        ? localizations.loginCreateAccount
        : localizations.signIn;

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
                usernameController: _usernameController,
                passwordController: _passwordController,
                emailFocusNode: _emailFocusNode,
                usernameFocusNode: _usernameFocusNode,
                passwordFocusNode: _passwordFocusNode,
                isSignUp: _isSignUp,
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
    required this.usernameController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.usernameFocusNode,
    required this.passwordFocusNode,
    required this.isSignUp,
    required this.onSubmitted,
  });

  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode usernameFocusNode;
  final FocusNode passwordFocusNode;
  final bool isSignUp;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        TextFormField(
          controller: emailController,
          focusNode: emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: localizations.loginEmail,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: (value) => _validateEmail(context, value),
          onFieldSubmitted: (_) {
            if (isSignUp) {
              usernameFocusNode.requestFocus();
              return;
            }
            passwordFocusNode.requestFocus();
          },
        ),
        if (isSignUp) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: usernameController,
            focusNode: usernameFocusNode,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: localizations.loginUsername,
              helperText: localizations.loginUsernameHint,
              prefixIcon: const Icon(Icons.alternate_email_outlined),
            ),
            validator: (value) => _validateUsername(context, value),
            onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            labelText: localizations.loginPassword,
            prefixIcon: const Icon(Icons.lock_outlined),
          ),
          validator: (value) => _validatePassword(context, value),
          onFieldSubmitted: (_) => onSubmitted(),
        ),
      ],
    );
  }

  String? _validateEmail(BuildContext context, String? value) {
    final localizations = AppLocalizations.of(context)!;
    final email = value?.trim() ?? '';
    if (email.isEmpty) return localizations.loginEmailRequired;
    if (!email.contains('@')) return localizations.loginEmailInvalid;
    return null;
  }

  String? _validateUsername(BuildContext context, String? value) {
    final localizations = AppLocalizations.of(context)!;
    final username = value?.trim() ?? '';
    final isValid = RegExp(r'^[a-zA-Z0-9_.]{2,20}$').hasMatch(username);
    if (username.isEmpty) return localizations.loginUsernameRequired;
    if (!isValid) return localizations.loginUsernameInvalid;
    return null;
  }

  String? _validatePassword(BuildContext context, String? value) {
    final localizations = AppLocalizations.of(context)!;
    final password = value ?? '';
    if (password.isEmpty) return localizations.loginPasswordRequired;
    if (password.length < 6) return localizations.loginPasswordTooShort;
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
    final localizations = AppLocalizations.of(context)!;

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
                isSignUp
                    ? localizations.loginCreateAccount
                    : localizations.signIn,
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
    final localizations = AppLocalizations.of(context)!;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(
        isSignUp
            ? localizations.loginAlreadyHaveAccount
            : localizations.loginNoAccount,
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
    final localizations = AppLocalizations.of(context)!;

    return TextButton.icon(
      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
      icon: const Icon(Icons.home_outlined),
      label: Text(localizations.backHome),
      style: TextButton.styleFrom(foregroundColor: CrazerColors.textSecondary),
    );
  }
}
