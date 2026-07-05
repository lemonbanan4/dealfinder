# CLAUDE.md

## Project: PrisPuls (DealFinder)
A high-performance affiliate deal aggregator built with Flutter/Dart.

## Design System: "Liquid Glass"
- **Theme**: Dark-mode only. Background: a deep bluish gradient, #0A192F → #112240
  (top-left to bottom-right), not a flat color — see `GlassColors.backgroundGradient`.
- **Aesthetic**: Glassmorphism/Liquid Glass. Use `BackdropFilter` with blur for all cards and bars.
  Card/container fills are translucent (`GlassColors.surface` tuned to the blue palette, ~50-70%
  alpha), not solid, so the gradient shows through.
- **Borders**: 1px soft white/light borders (`GlassColors.glowBorder`, translucent white) on all
  containers — not colored/blue-glow borders — to separate glass surfaces from the deep blue
  backdrop. `GlassColors.glowBorderHover` is a brighter white for hover/active states.
- **Accents**: LED-style blue/cyan glows for active states and primary buttons (e.g. selected nav
  items, primary CTAs) — distinct from the passive white container borders above.
- **Typography**: Clean, sans-serif, high data-density focus.

## UI/UX Directives
- **Layout Structure**: Shift from sidebar-navigation to a centered, max-width (1200px) layout.
- **Grid System**: Deal card grid is capped at 2 columns per row (not 3) — at 3-up, card images were too cramped at this card size; use a paginated or "Load More" implementation for scalability.
- **Glassmorphism**: 
    - Cards: translucent blue-tinted glass fill + blur + 1px soft white border (see above).
    - Hero Surface: A large, centered gradient-glass container spanning the main content area, housing all deal cards.
- **Header**: Replace sidebar with a sticky, centered horizontal glass-bar containing: Logo, Search, Category Dropdown, and Auth.
- **Feed toolbar**: Deliberately minimal — no region/sort/favorites-only/grid-list-toggle controls.
  The only feed-level action is a floating "Refresh" glass button docked to the top-right of the
  feed section; "Favorite" is a per-card action (top-right of each card), not a toolbar filter.
- **Footer**: Add a professional footer mirroring Plusshop (links, trust badges, policies).

## UI Components Requirements
- **Sticky Header**: A persistent top bar that follows scroll. 
  - Must include: Integrated search bar, user profile/auth icon, and a "Categories" dropdown button (triggered on hover/click).
  - Must NOT include: region/flag switcher, sort menu, favorites-only toggle, or a grid/list view
    toggle — the feed is grid-only now, and those controls were deliberately removed.
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