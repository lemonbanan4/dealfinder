import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              _GradientAuthButton(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [GlassColors.blue500, GlassColors.indigo600],
                ),
                glowColor: GlassColors.sky400,
                onPressed: state.loading
                    ? null
                    : () => notifier.submit(
                        _formKey,
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      ),
                child: state.loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        state.isLogin ? l10n.loginTitle : l10n.signUpTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
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
              _GoogleSignInButton(
                loading: _isGoogleLoading,
                label: _isGoogleLoading
                    ? l10n.signingIn
                    : l10n.continueWithGoogle,
                onPressed: _isGoogleLoading ? null : _signInWithGoogle,
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 12),
                _AppleSignInButton(
                  loading: _isAppleLoading,
                  label: _isAppleLoading
                      ? l10n.signingIn
                      : l10n.signInWithApple,
                  onPressed: _isAppleLoading ? null : _signInWithApple,
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

/// Shared shape/chrome for every gradient CTA on this page (the email/
/// password submit button, Google, Apple) — a glass-glow pill matching
/// this app's own button language (see GlassCard's hover glow), with the
/// gradient/glow color and inner content left to the caller so each
/// button can carry its own distinct identity rather than all three
/// looking like the same button in different colors.
class _GradientAuthButton extends StatelessWidget {
  const _GradientAuthButton({
    required this.gradient,
    required this.glowColor,
    required this.onPressed,
    required this.child,
  });

  final Gradient gradient;
  final Color glowColor;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.6,
      duration: const Duration(milliseconds: 150),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: glowColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Sign in with Google" — a blue-to-green diagonal gradient drawn from
/// Google's own brand blue/green (rather than the flat #131314 "official
/// dark button" fill), so it reads as unmistakably Google while still
/// looking distinct from the plain black Apple button next to it. The "G"
/// mark sits on a small white chip for legibility against the gradient —
/// Google's own multi-surface button assets use the same trick.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _GradientAuthButton(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4285F4), Color(0xFF34A853)],
      ),
      glowColor: const Color(0xFF4285F4),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/google_logo.svg',
                    height: 16,
                    width: 16,
                  ),
                ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Sign in with Apple" — a charcoal-to-black diagonal gradient rather
/// than a flat fill, so it reads with some depth (fitting this app's
/// Liquid Glass surfaces) while staying true to Apple's black-button
/// guideline (no color, white glyph/text, no border of its own — the
/// shared white-ish glow from [_GradientAuthButton] stands in for one).
class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _GradientAuthButton(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3A3A3C), Color(0xFF000000)],
      ),
      glowColor: Colors.white,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.apple, size: 20, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
