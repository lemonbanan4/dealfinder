import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider =
    NotifierProvider<LoginNotifier, LoginState>(
      () => LoginNotifier(FirebaseAuth.instance),
    );

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
      state = state.copyWith(
        loading: false,
        error: 'An unexpected error occurred.',
      );
    } finally {
      // In AutoDisposeNotifier, we can safely update loading if ref is still active
      try {
        state = state.copyWith(loading: false);
      } catch (_) {}
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      state = state.copyWith(error: 'Please enter a valid email.');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(loading: false, resetEmailSent: true);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e is FirebaseAuthException ? e.message : 'An unexpected error occurred.',
      );
    }
  }
}

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    void showForgotPasswordDialog() {
      final emailDialogController = TextEditingController();
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Reset Password'),
            content: TextField(
              controller: emailDialogController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final email = emailDialogController.text.trim();
                  if (email.isNotEmpty) {
                    await notifier.resetPassword(email);
                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'If an account exists, a password reset link has been sent.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Send Link'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(state.isLogin ? 'Login' : 'Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Please enter an email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: state.obscurePass,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                    return 'Please enter a password';
                  }
                  if (value!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              if (state.isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: showForgotPasswordDialog,
                    child: const Text('Forgot Password?'),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.loading
                    ? null
                    : () => notifier.submit(
                        formKey,
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.loading
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(state.isLogin ? 'Login' : 'Sign Up'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: notifier.toggleMode,
                child: Text(
                  state.isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
