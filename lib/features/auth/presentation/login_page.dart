import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/glass_colors.dart';
import '../../deals/presentation/user.dart' as domain;
import '../providers/auth_provider.dart';

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  () => LoginNotifier(FirebaseAuth.instance),
);

/// [LoginNotifier] has no [BuildContext] to resolve [AppLocalizations]
/// through, so its two internal fallback errors (as opposed to Firebase's
/// own [FirebaseAuthException.message], which is already localized text
/// from Firebase and passed through as-is) are these sentinels — the
/// widget's `ref.listen` (which does have context) swaps them for real
/// localized text before display.
const unexpectedErrorSentinel = '__unexpected_error__';
const invalidEmailSentinel = '__invalid_email__';

@immutable
class LoginState {
  const LoginState({
    this.isLogin = true,
    this.loading = false,
    this.obscurePass = true,
    this.error,
    this.resetEmailSent = false,
  });

  final bool isLogin;
  final bool loading;
  final bool obscurePass;
  final String? error;
  final bool resetEmailSent;

  LoginState copyWith({
    bool? isLogin,
    bool? loading,
    bool? obscurePass,
    String? error,
    bool? resetEmailSent,
    bool clearError = false,
  }) {
    return LoginState(
      isLogin: isLogin ?? this.isLogin,
      loading: loading ?? this.loading,
      obscurePass: obscurePass ?? this.obscurePass,
      error: clearError ? null : error ?? this.error,
      resetEmailSent: resetEmailSent ?? this.resetEmailSent,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  LoginNotifier(this._auth);

  final FirebaseAuth _auth;

  @override
  LoginState build() {
    return const LoginState();
  }

  void toggleMode() {
    state = state.copyWith(isLogin: !state.isLogin, clearError: true);
  }

  void toggleObscure() {
    state = state.copyWith(obscurePass: !state.obscurePass);
  }

  Future<void> submit(
    GlobalKey<FormState> formKey,
    String email,
    String password,
  ) async {
    if (!formKey.currentState!.validate()) return;

    state = state.copyWith(loading: true, clearError: true);

    try {
      if (state.isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: unexpectedErrorSentinel);
    } finally {
      // In AutoDisposeNotifier, we can safely update loading if ref is still active
      try {
        state = state.copyWith(loading: false);
      } catch (_) {}
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(error: invalidEmailSentinel);
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(loading: false, resetEmailSent: true);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e is FirebaseAuthException ? e.message : unexpectedErrorSentinel,
      );
    }
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      // Success/error/navigation are handled by the ref.listen in build() —
      // it reacts to authProvider regardless of which sign-in path triggered it.
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isAppleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithApple();
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final notifier = ref.read(loginProvider.notifier);
    final emailDialogController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.resetPasswordTitle),
          content: TextField(
            controller: emailDialogController,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              hintText: l10n.enterYourEmailAddress,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final email = emailDialogController.text.trim();
                if (email.isNotEmpty) {
                  await notifier.resetPassword(email);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.resetLinkSentMessage),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.sendLink),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.error != null) {
        final message = switch (next.error!) {
          unexpectedErrorSentinel => l10n.unexpectedError,
          invalidEmailSentinel => l10n.pleaseEnterValidEmail,
          final e => e,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    // Single source of truth for "the user is now signed in", regardless of
    // whether email/password (loginProvider, above) or Google (authProvider,
    // via _signInWithGoogle) completed the sign-in — both ultimately update
    // the same underlying Firebase auth-state stream that authProvider wraps.
    ref.listen<AsyncValue<domain.User?>>(authProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && mounted) {
            Navigator.of(context).pop(true);
          }
        },
        error: (error, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isLogin ? l10n.loginTitle : l10n.signUpTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.emailLabel),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    (value?.isEmpty ?? true) ? l10n.pleaseEnterEmail : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: state.obscurePass,
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.obscurePass
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: notifier.toggleObscure,
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.pleaseEnterPassword;
                  }
                  if (value!.length < 6) {
                    return l10n.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              if (state.isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(l10n.forgotPassword),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.loading
                    ? null
                    : () => notifier.submit(
                        _formKey,
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.loading
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(state.isLogin ? l10n.loginTitle : l10n.signUpTitle),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: theme.colorScheme.outlineVariant),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.orDivider,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: theme.colorScheme.outlineVariant),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                icon: _isGoogleLoading
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? GlassColors.glowBorderHover : null,
                        ),
                      )
                    : Image.asset('assets/images/google_logo.png', height: 20),
                label: Text(
                  _isGoogleLoading ? l10n.signingIn : l10n.continueWithGoogle,
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? GlassColors.background : null,
                  foregroundColor: isDark
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  side: BorderSide(
                    color: isDark
                        ? GlassColors.glowBorder
                        : theme.colorScheme.outlineVariant,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isAppleLoading ? null : _signInWithApple,
                  icon: _isAppleLoading
                      ? SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? GlassColors.glowBorderHover : null,
                          ),
                        )
                      : Icon(
                          Icons.apple,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                  label: Text(
                    _isAppleLoading ? l10n.signingIn : l10n.continueWithApple,
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? GlassColors.background : null,
                    foregroundColor: isDark
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    side: BorderSide(
                      color: isDark
                          ? GlassColors.glowBorder
                          : theme.colorScheme.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: notifier.toggleMode,
                child: Text(
                  state.isLogin ? l10n.noAccountSignUp : l10n.haveAccountLogin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
