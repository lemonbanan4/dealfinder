import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import 'auth_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePass = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authProvider.notifier);
      if (_isLogin) {
        await auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      } else {
        await auth.createAccount(_emailCtrl.text.trim(), _passCtrl.text);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    } catch (e) {
      setState(() => _error = 'Unexpected error — check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _friendlyError(String code) => switch (code) {
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Invalid email or password.',
    'email-already-in-use' => 'An account already exists with this email.',
    'weak-password' => 'Password must be at least 6 characters.',
    'invalid-email' => 'Please enter a valid email address.',
    'too-many-requests' => 'Too many attempts. Try again later.',
    _ => 'Authentication failed ($code).',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _Background(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _GlassCard(
                    child: _FormContent(
                      formKey: _formKey,
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      confirmCtrl: _confirmCtrl,
                      isLogin: _isLogin,
                      loading: _loading,
                      obscurePass: _obscurePass,
                      error: _error,
                      onToggleMode: () => setState(() {
                        _isLogin = !_isLogin;
                        _error = null;
                      }),
                      onToggleObscure: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      onSubmit: _submit,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background ─────────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF060710), Color(0xFF0D1535), Color(0xFF060710)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Decorative blobs so the blur has something to act on
        Positioned(
          top: -60,
          left: -80,
          child: _Blob(color: const Color(0xFF006EFF), size: 280),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: _Blob(color: const Color(0xFF0044AA), size: 220),
        ),
        Positioned(
          top: 200,
          right: 40,
          child: _Blob(color: const Color(0xFF00B4FF), size: 120),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(45),
      ),
    );
  }
}

// ── Glass card ─────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(28)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Form content ───────────────────────────────────────────────────────────────

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.isLogin,
    required this.loading,
    required this.obscurePass,
    required this.error,
    required this.onToggleMode,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool isLogin;
  final bool loading;
  final bool obscurePass;
  final String? error;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  // 1. Define the method right inside this class so onTap can see it!
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithPopup(googleProvider);

      // 2. Guard the context to fix the 'async gaps' warning
      if (!context.mounted) return;

      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged in!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Logo(),
          const SizedBox(height: 24),
          Text(
            isLogin ? 'Welcome back' : 'Create account',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isLogin
                ? 'Sign in to sync your price alerts'
                : 'Start tracking deals across devices',
            style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _GlassField(
            controller: emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          _GlassField(
            controller: passCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: obscurePass,
            textInputAction: isLogin
                ? TextInputAction.done
                : TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePass
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: Colors.white.withAlpha(140),
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Min 6 characters' : null,
            onFieldSubmitted: isLogin ? (_) => onSubmit() : null,
          ),
          if (!isLogin) ...[
            const SizedBox(height: 12),
            _GlassField(
              controller: confirmCtrl,
              label: 'Confirm password',
              icon: Icons.lock_outline,
              obscureText: obscurePass,
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  v != passCtrl.text ? 'Passwords do not match' : null,
              onFieldSubmitted: (_) => onSubmit(),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757).withAlpha(30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF4757).withAlpha(80),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF4757),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(
                        color: Color(0xFFFF4757),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _PrimaryButton(
            label: isLogin ? 'Sign In' : 'Create Account',
            loading: loading,
            onTap: onSubmit,
          ),
          const SizedBox(height: 20),
          _Divider(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SocialButton(
                  label: 'Google',
                  icon: Icons.g_mobiledata_rounded,
                  onTap: () => _signInWithGoogle(context),
                ),
              ),
              const SizedBox(width: 12),
              // Expanded(
              //   child: _SocialButton(
              //     label: 'Apple',
              //     icon: Icons.apple,
              //     onTap: () => _showSocialStub(context, 'Apple'),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onToggleMode,
            child: Text(
              isLogin
                  ? "Don't have an account? Sign up"
                  : 'Already have an account? Sign in',
              style: TextStyle(
                color: Colors.white.withAlpha(160),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // static void _showSocialStub(BuildContext context, String provider) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         '$provider sign-in requires Firebase project configuration.',
  //       ),
  //       behavior: SnackBarBehavior.floating,
  //       duration: const Duration(seconds: 3),
  //     ),
  //   );
  // }
}

// ── Logo mark ──────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF006EFF), Color(0xFF00B4FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006EFF).withAlpha(100),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_offer_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

// ── Glass text field ───────────────────────────────────────────────────────────

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(140), fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white.withAlpha(140), size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withAlpha(15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00B4FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF4757)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF4757), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF4757), fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// ── Primary CTA button ─────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF006EFF), Color(0xFF00B4FF)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006EFF).withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Divider with label ─────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withAlpha(30), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withAlpha(30), height: 1)),
      ],
    );
  }
}

// ── Social button ──────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withAlpha(40)),
          backgroundColor: Colors.white.withAlpha(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
