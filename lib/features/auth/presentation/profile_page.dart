import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../deals/presentation/feed_page.dart'
    show favoritesProvider, feedFiltersProvider;
import '../../deals/providers/recently_viewed_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../../../widgets/glass_dialog.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _supabase = Supabase.instance.client;

  Future<void> _signOut() async {
    final confirm = await showGlassDialog<bool>(
      context: context,
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
    );
    if (confirm != true) return;
    await _handlePostSignOutCleanup();
  }

  Future<void> _deleteAccount() async {
    final confirm = await showGlassDialog<bool>(
      context: context,
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
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF4757)),
          child: const Text('Delete'),
        ),
      ],
    );

    if (confirm != true) return;

    // It's good practice to check if the widget is still mounted before showing a dialog.
    if (!mounted) return;

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
      await _handlePostSignOutCleanup(isAccountDeletion: true);

      if (mounted) {
        Navigator.pop(context); // Dismiss profile page
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Dismiss loading dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account. Please try again.'),
            backgroundColor: Color(0xFFFF4757),
          ),
        );
      }
    }
  }

  Future<void> _handlePostSignOutCleanup({
    bool isAccountDeletion = false,
  }) async {
    await FirebaseAuth.instance.signOut();
    ref.invalidate(feedFiltersProvider);
    ref.read(recentlyViewedProvider.notifier).clear();
    if (mounted && !isAccountDeletion) Navigator.pop(context);
  }

  Future<void> _updateDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ctrl = TextEditingController(text: user.displayName);
    final newName = await showGlassDialog<String>(
      context: context,
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
    );

    if (newName != null && newName != user.displayName) {
      await user.updateDisplayName(newName.isEmpty ? null : newName);
      setState(() {});
    }
  }

  Future<void> _updateProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ctrl = TextEditingController(text: user.photoURL);
    final newUrl = await showGlassDialog<String>(
      context: context,
      title: const Text('Update Profile Picture'),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(
          hintText: 'Enter image URL (https://...)',
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
    );

    if (newUrl != null && newUrl != user.photoURL) {
      if (newUrl.isNotEmpty && Uri.tryParse(newUrl)?.isAbsolute == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image URL must start with https://'),
              backgroundColor: Color(0xFFFF4757),
            ),
          );
        }
        return;
      }
      await user.updatePhotoURL(newUrl.isEmpty ? null : newUrl);
      setState(() {});
    }
  }

  Stream<List<Map<String, dynamic>>> _userAlertsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _supabase
        .from('price_alerts')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.uid)
        .map(
          (maps) => maps.where((item) => item['is_active'] == true).toList(),
        );
  }

  Future<void> _deleteAlert(String alertId) async {
    try {
      await _supabase.from('price_alerts').delete().eq('id', alertId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert removed successfully.')),
        );
      }
    } catch (e) {
      debugPrint('Failed to delete alert: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF12131A);
    final iconColor = isDark
        ? const Color(0xFF8A8AA0)
        : const Color(0xFF5A5A78);

    return userAsync.when(
      data: (user) => Scaffold(
        appBar: AppBar(title: const Text('Profile & Settings')),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            if (user != null) ...[
              Center(
                child: const Icon(
                  Icons.account_circle,
                  size: 72,
                  color: Color(0xFF00B4FF),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.email ?? 'No email associated',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFF252638)),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                child: Text(
                  'YOUR ACTIVE PRICE ALERTS',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _userAlertsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final alerts = snapshot.data ?? [];
                  if (alerts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12131A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF252638)),
                      ),
                      child: const Text(
                        'You haven\'t set up any active price alerts yet.',
                        style: TextStyle(
                          color: Color(0xFF5A5A78),
                          fontSize: 13,
                        ),
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF12131A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF252638)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: alerts.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFF252638)),
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return ListTile(
                          title: Text(
                            alert['product_title'] ?? 'Product',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Target: ${alert['target_price']} ${alert['currency']}',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFFF4757),
                              size: 20,
                            ),
                            onPressed: () => _deleteAlert(alert['id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFF252638)),
            ],

            ListTile(
              leading: Icon(Icons.brightness_6, color: iconColor),
              title: Text(
                'Theme Appearance',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<AppTheme>(
                  value: themeMode,
                  dropdownColor: isDark
                      ? const Color(0xFF1A1B2A)
                      : Colors.white,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: iconColor),
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
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(themeProvider.notifier).updateTheme(mode);
                    }
                  },
                ),
              ),
            ),
            const Divider(color: Color(0xFF252638)),

            ListTile(
              leading: Icon(Icons.badge_outlined, color: iconColor),
              title: Text(
                'Update Display Name',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right, color: iconColor),
              onTap: _updateDisplayName,
            ),
            ListTile(
              leading: Icon(Icons.image_outlined, color: iconColor),
              title: Text(
                'Update Profile Picture',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right, color: iconColor),
              onTap: _updateProfilePicture,
            ),
            const Divider(color: Color(0xFF252638)),

            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: iconColor),
              title: Text(
                'Privacy Policy',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right, color: iconColor),
              onTap: () => _showPlaceholderDialog('Privacy Policy'),
            ),
            ListTile(
              leading: Icon(Icons.description_outlined, color: iconColor),
              title: Text(
                'Terms of Service',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right, color: iconColor),
              onTap: () => _showPlaceholderDialog('Terms of Service'),
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: iconColor),
              title: Text(
                'About Us',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right, color: iconColor),
              onTap: () => _showPlaceholderDialog('About Us'),
            ),

            if (user != null) ...[
              const Divider(color: Color(0xFF252638)),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFFF4757)),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color(0xFFFF4757),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
                  style: TextStyle(
                    color: Color(0xFFFF4757),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _deleteAccount,
              ),
            ],
          ],
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  void _showPlaceholderDialog(String title) {
    showGlassDialog(
      context: context,
      title: Text(title),
      content: Text(
        'The $title section will be available soon as part of the launch deployment.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
