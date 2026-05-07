import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/styles/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );
      if (!mounted) return;

      context.showSnackBar('Mot de passe mis a jour avec succes.');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
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

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Renseignez votre nouveau mot de passe';
    if (password.length < 6) return '6 caracteres minimum';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmation = value ?? '';
    if (confirmation.isEmpty) return 'Confirmez votre nouveau mot de passe';
    if (confirmation != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Nouveau mot de passe',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 48),
                const Icon(
                  Icons.lock_reset_outlined,
                  size: 56,
                  color: CrazerColors.lime,
                ),
                const SizedBox(height: 20),
                Text(
                  'Choisissez un nouveau mot de passe',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Une fois valide, votre mot de passe sera mis a jour immediatement.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: const InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          prefixIcon: Icon(Icons.lock_outlined),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: const InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: Icon(Icons.verified_user_outlined),
                        ),
                        validator: _validateConfirmPassword,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Mettre a jour le mot de passe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (_) => false);
                        },
                  child: const Text(
                    'Retour a la connexion',
                    style: TextStyle(
                      color: CrazerColors.lime,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
