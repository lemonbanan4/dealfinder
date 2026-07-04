# CLAUDE.md

## Project: PrisPuls (DealFinder)
A high-performance affiliate deal aggregator built with Flutter/Dart.

## Design System: "Liquid Glass"
- **Theme**: Dark-mode only. Background: #0B0E14 (Deep Charcoal).
- **Aesthetic**: Glassmorphism/Liquid Glass. Use `BackdropFilter` with blur for all cards and bars.
- **Borders**: 1px subtle glowing borders (#2A3A5A) on all containers.
- **Accents**: LED-style blue/cyan glows for active states and primary buttons.
- **Typography**: Clean, sans-serif, high data-density focus.

## UI Components Requirements
- **Sticky Header**: A persistent top bar that follows scroll. 
  - Must include: Integrated search bar, user profile/auth icon, and a "Categories" dropdown button (triggered on hover/click).
- **Deal Cards**: 
  - Must include: Visual price tracking sparkline (use `fl_chart`) inside the card.
  - Cards must use the Glassmorphic container style with glowing borders.
- **Navigation**: Move category logic from country toggles to a centralized "Categories" dropdown in the sticky header.

## Development Constraints
- **Security**: All CSP requirements must be met; no inline scripts/styles.
- **Performance**: Use 'mounted' checks for all async navigation. Keep builds web-compliant (avoid 'dart:html' / 'package:js' if possible).
- **Commands**:
  - Build: `flutter build web --release`
  - Deploy: `firebase deploy --only hosting`
  - Lint: `flutter analyze`
  - Run: `flutter run`