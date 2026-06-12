import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../deals/presentation/feed_page.dart'
    show favoritesProvider, showFavoritesOnlyProvider;
import '../../alerts/providers/alerts_provider.dart';
import '../../alerts/providers/alert_configs_provider.dart';
import '../../alerts/providers/unread_alerts_provider.dart';
import '../../../core/constants.dart';
import '../../settings/providers/theme_provider.dart';
import '../../legal/presentation/privacy_policy_page.dart';
import '../../legal/presentation/terms_of_service_page.dart';
import '../../legal/presentation/about_us_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();
    await _clearLocalData(ref);

    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _clearLocalData(WidgetRef ref) async {
    // 1. Wipe offline caches
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorite_products_pref');
    await Hive.box<String>(HiveBoxes.alerts).clear();

    // 2. Invalidate Riverpod providers to reset their state across the UI
    ref.invalidate(favoritesProvider);
    ref.invalidate(alertsProvider);
    ref.invalidate(alertConfigsProvider);
    ref.invalidate(unreadAlertsProvider);
    ref.invalidate(showFavoritesOnlyProvider);
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF4757),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-north1',
      ).httpsCallable('delete_account');

      await callable.call();
      await FirebaseAuth.instance.signOut();
      await _clearLocalData(ref);

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        Navigator.pop(context); // Dismiss profile page
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Dismiss loading dialog

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account. Please try again.'),
            backgroundColor: Color(0xFFFF4757),
          ),
        );
      }
    }
  }

  Future<void> _updateDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ctrl = TextEditingController(text: user.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Display Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Enter new name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName != user.displayName) {
      await user.updateDisplayName(newName);
      await user.reload();
      if (mounted) setState(() {});
    }
  }

  Future<void> _updateProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ctrl = TextEditingController(text: user.photoURL);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile Picture'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Enter image URL (e.g., https://...)',
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newUrl != null && newUrl != user.photoURL) {
      if (newUrl.isNotEmpty && !newUrl.startsWith('https://')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image URL must be secure (start with https://)'),
              backgroundColor: Color(0xFFFF4757),
            ),
          );
        }
        return;
      }
      await user.updatePhotoURL(newUrl.isEmpty ? null : newUrl);
      await user.reload();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          if (user != null) ...[
            if (user.photoURL != null && user.photoURL!.isNotEmpty)
              CircleAvatar(
                radius: 32,
                backgroundImage: CachedNetworkImageProvider(user.photoURL!),
                backgroundColor: Colors.transparent,
              )
            else
              const Icon(
                Icons.account_circle,
                size: 64,
                color: Color(0xFF5A5A78),
              ),
            const SizedBox(height: 16),
            Text(
              user.displayName?.isNotEmpty == true
                  ? user.displayName!
                  : 'No display name',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user.email ?? 'No email',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8A8AA0)),
            ),
            const SizedBox(height: 8),
            Text(
              user.emailVerified ? 'Email Verified' : 'Email Not Verified',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: user.emailVerified
                    ? const Color(0xFF00E676)
                    : const Color(0xFFFF4757),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Appearance'),
            trailing: DropdownButton<AppTheme>(
              value: themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: AppTheme.system,
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: AppTheme.light,
                  child: Text('Light Mode'),
                ),
                DropdownMenuItem(
                  value: AppTheme.dark,
                  child: Text('Dark Mode'),
                ),
                DropdownMenuItem(
                  value: AppTheme.amoled,
                  child: Text('AMOLED Black'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeProvider.notifier).updateTheme(mode);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Update Display Name'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _updateDisplayName,
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Update Profile Picture'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _updateProfilePicture,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Us'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsPage()),
            ),
          ),
          if (user != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFF4757)),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Color(0xFFFF4757)),
              ),
              onTap: _signOut,
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Color(0xFFFF4757),
              ),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Color(0xFFFF4757)),
              ),
              onTap: _deleteAccount,
            ),
          ],
        ],
      ),
    );
  }
}
