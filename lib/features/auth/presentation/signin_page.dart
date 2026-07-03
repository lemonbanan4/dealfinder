import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'forgot_password_page.dart';
import '../providers/validators.dart';
import 'signup_page.dart';
import '../providers/auth_provider.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    // Validate the form first.
    if (_formKey.currentState?.validate() ?? false) {
      // If valid, attempt to sign in.
      // The loading/error state is handled by listening to the authProvider.
      ref
          .read(authProvider.notifier)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  Future<void> _signInWithGoogle() async {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the auth provider to handle navigation and errors.
    ref.listen<AsyncValue<dynamic>>(authProvider, (previous, next) {
      next.when(
        data: (user) {
          // On success (user is not null), pop the page.
          if (user != null && mounted) {
            Navigator.of(context).pop();
          }
        },
        error: (error, stackTrace) {
          // On error, show a SnackBar.
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        loading: () {
          // Loading state is handled by the button's appearance.
        },
      );
    });

    // Watch the provider to get the current loading state for the UI.
    final authState = ref.watch(authProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => Validators.validateEmail(value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => Validators.validatePassword(value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _signIn,
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 3),
                    )
                  : const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            // --- Google Sign In Button ---
            ElevatedButton.icon(
              onPressed: isLoading ? null : _signInWithGoogle,
              icon: Image.asset(
                'assets/images/google_logo.png', // Make sure you have this asset
                height: 22.0,
              ),
              label: const Text('Sign In with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            // ---
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Hint: Use any email and "password" as the password.',
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text('Don\'t have an account? Create one'),
            ),
          ],
        ),
      ),
    );
  }
}
