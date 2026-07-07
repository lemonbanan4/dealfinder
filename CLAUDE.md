# CLAUDE.md

## Project: PrisPuls (DealFinder)
A high-performance affiliate deal aggregator built with Flutter/Dart.

## Design System: "Liquid Glass"
All tokens below live in **`lib/theme/glass_colors.dart`** — the single source of truth for every
glass surface in the app (`GlassCard`, `GlassContainer`, the top nav bar, deal cards, dropdowns,
footer, ...). There used to be a second, divergent token file (`AppStyles`) that only `GlassCard`
read from; it's gone now specifically because that split caused visible inconsistencies (the top
nav bar's own background reading as a different surface than the page/cards behind it). Don't
reintroduce a second token source — add new tokens to `GlassColors` instead.
- **Theme**: Dark-mode only. **Flat** background, `#0A0F1E` (`GlassColors.background`) — not a
  gradient. (An earlier version of this app used a diagonal `#0A192F → #112240` gradient; that's
  what caused the inconsistency above, since a translucent glass fill tinted differently depending
  on *where* on the gradient it sat. A flat backdrop means every glass surface's fill reads
  identically regardless of position on screen.)
- **Aesthetic**: Glassmorphism ("glass-card"). `BackdropFilter` blur (`GlassColors.glassBlurSigma`,
  16px) + a translucent dark-navy fill (`GlassColors.glassFill`, `rgba(8,12,28,0.45)`) + a soft
  white 8%-alpha border (`GlassColors.glowBorder`) + a soft black drop shadow
  (`GlassColors.glassShadow`) for every card/bar. On hover/interactive surfaces: border shifts to a
  sky-blue glow (`GlassColors.glowBorderHover`, `rgba(56,189,248,0.25)`), plus a lift
  (`translateY(-3px) scale(1.01)`) and a combined black+sky glow shadow
  (`GlassColors.glassHoverShadow`) — see `GlassCard`.
- **Accents** (Tailwind hex, used as plain named colors — no compliance/region meaning attached):
  `blue500 #3B82F6`, `indigo600 #4F46E5`, `emerald400 #34D399` (also `priceAccent` — money/price
  text and sparklines), `blue400 #60A5FA`, `amber400 #FBBF24`, `rose500 #F43F5E` (danger/alerts),
  `sky400 #38BDF8` (neon glow / hover border).
- **Neon glow utilities**: `neonBorderBlue`/`neonGlowBlue`, `neonBorderEmerald`/`neonGlowEmerald`,
  `neonBorderRose`/`neonGlowRose`, `neonTextBlue` (text shadow) — subtle glow accents, not the
  primary border treatment (that's `glowBorder`/`glowBorderHover` above).
- **Typography**: Inter (body/label text) + Space Grotesk 500–700 (display/headline/title text),
  loaded via `google_fonts` and assembled once in `app.dart`'s `_appTextTheme`. Text-scale colors:
  `GlassColors.textHeading` (slate-100), `textBody` (slate-300), `textMuted` (slate-400),
  `textPlaceholder` (slate-500).

## UI/UX Directives
- **Layout Structure**: Shift from sidebar-navigation to a centered, max-width (1200px) layout.
- **Grid System**: Deal card grid is capped at 2 columns per row (not 3) — at 3-up, card images were too cramped at this card size; use a paginated or "Load More" implementation for scalability.
- **Glassmorphism**: 
    - Cards: translucent blue-tinted glass fill + blur + 1px soft white border (see above).
    - Hero Surface: A large, centered gradient-glass container spanning the main content area, housing all deal cards.
- **Header**: Replace sidebar with a sticky, centered horizontal glass-bar containing: Logo, Search, Category Dropdown, and Auth.
  `GlassTopNavBar` (the desktop/tablet version) lives in `feed_page.dart` alongside `FeedPage`
  itself, not in `adaptive_scaffold.dart` (which just arranges it + the page switcher) — deliberate,
  so the feed and the header it's paired with are defined/styled in one place.
- **Feed toolbar**: Deliberately minimal — no region/favorites-only/grid-list-toggle controls. The
  one exception is **Sort** (`SortDropdown`, right-aligned above the main grid: Best Deals / Price
  Low-High / Price High-Low / Newest) — reinstated deliberately since it's the #1 control users
  expect on an affiliate deal site; it is not part of the sticky header. The only feed-level action
  in the header itself is a floating "Refresh" glass button docked to the top-right of the feed
  section; "Favorite" is a per-card action (top-right of each card), not a toolbar filter.
- **Footer**: Add a professional footer mirroring Plusshop (links, trust badges, policies).

## UI Components Requirements
- **Sticky Header**: A persistent top bar that follows scroll. 
  - Must include: Integrated search bar, user profile/auth icon, and a "Categories" dropdown button (triggered on hover/click).
  - Must NOT include: region/flag switcher, favorites-only toggle, or a grid/list view toggle — the
    feed is grid-only now, and those controls were deliberately removed. Sort lives above the grid
    itself (see `SortDropdown` in "Feed toolbar" above), not in this header.
- **Deal Cards**: 
  - Must include: Visual price tracking sparkline (use `fl_chart`) inside the card.
  - Cards must use the Glassmorphic container style with soft white/light borders (not colored glow borders).
- **Navigation**: Move category logic from country toggles to a centralized "Categories" dropdown in the sticky header.

## Development Constraints
- **Security**: All CSP requirements must be met. `'unsafe-inline'` is a deliberate, necessary exception for both `script-src` and `style-src` — the Firebase JS SDK injects inline `<script>` tags at runtime (auth/App Check helpers) and Flutter's CanvasKit web engine injects inline `<style>`/style attributes for text measurement and canvas positioning; without it the app hangs on the loading spinner forever. See the comment above the CSP meta tag in `web/index.html` for the full per-directive rationale. Beyond that exception, no other inline scripts/styles and no unnecessary host allowlisting.
- **Performance**: Use 'mounted' checks for all async navigation. Keep builds web-compliant (avoid 'dart:html' / 'package:js' if possible).
- **Commands**:
  - Build: `flutter build web --release`
  - Deploy: `firebase deploy --only hosting`
  - Lint: `flutter analyze`
  - Run: `flutter run`