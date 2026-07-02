import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/signin_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/presentation/settings_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: ref.watch(authProvider).when(
            data: (user) {
              if (user == null) {
                return const _AuthPromptView();
              }
              return _UserProfileView(user: user);
            },
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
    );
  }
}

/// A widget to display when the user is logged in.
class _UserProfileView extends ConsumerWidget {
  const _UserProfileView({required this.user});
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: const Text('Email'),
          subtitle: Text(user.email ?? 'No email provided'),
        ),
        const Divider(),
        Center(
          child: FilledButton.tonal(
            onPressed: () async {
              // Improvement 5: confirm before signing out, consistent with
              // the pattern in settings_page_pro.dart
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out?'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirmed ?? false) {
                ref.read(authProvider.notifier).signOut();
              }
            },
            child: const Text('Sign Out'),
          ),
        ),
      ],
    );
  }
}

/// A widget to display when the user is logged out.
class _AuthPromptView extends StatelessWidget {
  const _AuthPromptView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign in to save favorites and manage your profile.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SignInPage()),
              );
            },
            child: const Text('Sign In or Create Account'),
          ),
        ],
      ),
    );
  }
}
