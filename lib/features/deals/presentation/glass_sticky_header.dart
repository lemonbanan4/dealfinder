import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/app_logo.dart';
import '../../../widgets/glass_container.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/providers/auth_provider.dart';
// Deferred — see the identical import in feed_page.dart for why.
import '../../settings/presentation/settings_page.dart'
    deferred as settings_lib;
import 'feed_page.dart';
import 'glass_categories_menu.dart';
import 'glass_search_field.dart';

/// The feed's own narrow/mobile-only header: logo, Categories dropdown,
/// search field, and the auth icon.
///
/// On wide screens there is no equivalent — the app-level `_GlassTopNavBar`
/// (see adaptive_scaffold.dart) already covers logo/tabs/categories/search/
/// auth, and the feed no longer has its own toolbar of secondary filters
/// (region, sort, favorites-only, grid/list) — refresh is a floating action
/// over the feed content instead (see `_FloatingRefreshButton`). On narrow
/// screens there is no top nav bar (mobile uses a bottom NavigationBar), so
/// this keeps its own logo, Categories dropdown, search field, and auth icon.
class GlassStickyHeader extends ConsumerWidget implements PreferredSizeWidget {
  const GlassStickyHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = ref.watch(searchControllerProvider);
    final searchFocusNode = ref.watch(searchFocusNodeProvider);

    return GlassContainer(
      borderRadius: 0,
      enableHoverAnimation: false,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 8,
        16,
        12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  cancelPendingSearchUpdate(ref);
                  searchController.clear();
                  ref.read(feedFiltersProvider.notifier).clear();
                  ref.read(feedGoHomeSignalProvider.notifier).state++;
                },
                child: const AppLogo(),
              ),
              const Spacer(),
              const _AuthIcon(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Capped width — GlassCategoriesMenu's button has no flex
              // sibling of its own, so once a long category name is
              // selected (some Swedish category labels run long), its
              // full-text natural width was a hard demand that could
              // squeeze the Expanded search field next to it down to a
              // few unusable pixels on a narrow phone. The button's own
              // label already has TextOverflow.ellipsis, but ellipsis only
              // ever engages once the button itself has a bounded width to
              // truncate within.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: const GlassCategoriesMenu(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassSearchField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: (value) => handleSearchChanged(ref, value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Auth / profile icon ───────────────────────────────────────────────────────

class _AuthIcon extends ConsumerWidget {
  const _AuthIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (user) => IconButton(
        tooltip: user != null ? 'Profile' : 'Sign In',
        icon: Icon(
          user != null ? Icons.account_circle : Icons.person_outline,
          color: Colors.white,
        ),
        onPressed: () async {
          if (user != null) {
            await settings_lib.loadLibrary();
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => settings_lib.SettingsPage(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
      ),
      loading: () => const SizedBox(width: 48),
      error: (e, s) => const Icon(Icons.error, color: Colors.white),
    );
  }
}
