# DealFinder Pro

A next-level deal aggregator and price-alert app built with Flutter, targeting both **Web (WASM)** and **Mobile** from a single codebase. Get deals on your radar before they're gone. DealFinder Pro scrapes product listings, normalises prices into local currencies (NOK/SEK), and fires user-defined alerts when prices drop below a threshold.

---

## Table of Contents

1. [Feature Overview](#feature-overview)
2. [Architecture](#architecture)
3. [State Management — Riverpod](#state-management--riverpod)
4. [Scraping Strategy](#scraping-strategy)
5. [Currency Conversion](#currency-conversion)
6. [Price Alerts](#price-alerts)
7. [Adaptive UI](#adaptive-ui)
8. [Directory Structure](#directory-structure)
9. [Implementation Plan](#implementation-plan)
10. [Getting Started](#getting-started)

---

## Feature Overview

| Feature | Description |
|---|---|
| Deal aggregation | Fetch and normalise listings from multiple sources via HTTP + HTML scraping |
| Source management | Add/remove scrape sources; configure per-source selectors |
| Local currency | Live NOK / SEK conversion via open exchange-rate API (ECB fallback) |
| Price alerts | Per-item threshold alerts; persisted locally, evaluated on every refresh |
| Adaptive layout | Responsive shell: sidebar nav on wide screens, bottom-nav on mobile / narrow web |
| Offline cache | Hive-backed deal cache so the app is usable without a network |
| Background refresh | Periodic scrape scheduled via `workmanager` on mobile; SSE / polling on web |

---

## Architecture

```
┌───────────────────────────────────────────────────────┐
│                   Flutter Shell (UI)                  │
│  AdaptiveScaffold ─ pages: Feed | Search | Alerts | Settings │
└────────────────────────┬──────────────────────────────┘
                         │ reads/watches
┌────────────────────────▼──────────────────────────────┐
│              Riverpod Provider Layer                  │
│  dealFeedProvider · alertsProvider · settingsProvider │
│  currencyProvider · scraperStatusProvider             │
└──────┬────────────────────────────────┬───────────────┘
       │ calls                          │ calls
┌──────▼───────────┐          ┌─────────▼──────────────┐
│  Scraper Service │          │  Currency Service       │
│  (HTTP + parser) │          │  (ECB / open-rates API) │
└──────┬───────────┘          └─────────┬───────────────┘
       │                                │
┌──────▼────────────────────────────────▼───────────────┐
│                   Repository Layer                    │
│  DealRepository · AlertRepository · CurrencyCache    │
└──────────────────────────┬────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────┐
│               Local Persistence (Hive)                │
│  deals_box · alerts_box · settings_box · rates_box    │
└───────────────────────────────────────────────────────┘
```

### Key Layers

| Layer | Responsibility |
|---|---|
| **UI** | Adaptive widgets; pure read from providers |
| **Providers** | Riverpod `AsyncNotifier` / `Notifier`; orchestrate service calls |
| **Services** | Stateless business logic (scraping, currency, alert evaluation) |
| **Repositories** | Hive I/O + in-memory caching; abstract away storage detail |
| **Models** | Freezed data classes; JSON serialisable |

---

## State Management — Riverpod

All state is managed with **Riverpod 2** (`flutter_riverpod` + `riverpod_annotation`).

- `dealFeedProvider` — `AsyncNotifier<List<Deal>>`; triggers scraper, sorts by price, merges currencies
- `alertsProvider` — `Notifier<List<PriceAlert>>`; CRUD + evaluation logic
- `currencyProvider` — `FutureProvider<ExchangeRates>`; cached with a 6-hour TTL
- `settingsProvider` — `Notifier<AppSettings>`; preferred currency, enabled sources, refresh interval
- `scraperStatusProvider` — `StateProvider<ScraperStatus>`; surface loading / error state in UI

Code generation: `riverpod_generator` + `build_runner`.

---

## Scraping Strategy

Because the app targets WASM web, raw TCP scrapers are impossible in the browser. The approach:

1. **Mobile / desktop** — `package:http` fetches HTML directly; `package:html` (css_selectors) parses listings.
2. **Web** — requests are proxied through a thin backend-for-frontend (BFF) service (Dart `shelf` or serverless function); the Flutter web client calls the BFF's JSON REST API.
3. **Source config** — each source is described by a `ScraperConfig` (base URL, list selector, title/price/link selectors, optional pagination). Configs are stored in Hive and editable in Settings.

---

## Currency Conversion

- Primary: European Central Bank (ECB) daily XML feed — free, no key required.
- Fallback: `open.er-api.com` (free tier, requires no auth for limited usage).
- Rates cached in Hive with a timestamp; refreshed on app start and every 6 hours.
- Supported display currencies: **NOK**, **SEK**, **EUR**, **USD** (user-selectable).
- All internal prices stored in EUR; converted at display time.

---

## Price Alerts

- User sets a `targetPrice` (in their chosen display currency) per deal or search query.
- `AlertEvaluationService` runs after every scraper refresh, compares current price (converted) against threshold.
- Triggered alerts are surfaced via:
  - In-app banner / badge on the Alerts tab.
  - `flutter_local_notifications` on mobile.
  - Web Notifications API (via `js` interop) on web.

---

## Adaptive UI

```
< 600 dp wide          ≥ 600 dp wide
┌──────────┐           ┌──────┬─────────────┐
│  Content │           │ Nav  │   Content   │
│          │           │ Rail │             │
├──────────┤           │      │             │
│ Bottom   │           │      │             │
│   Nav    │           └──────┴─────────────┘
└──────────┘
```

Implemented via a single `AdaptiveScaffold` widget that switches between `NavigationBar` (mobile) and `NavigationRail` (wide). No separate web/mobile entry points — one `main.dart`.

---

## Directory Structure

```
lib/
├── main.dart
├── app.dart                    # MaterialApp + ProviderScope
├── core/
│   ├── constants.dart
│   ├── extensions/
│   └── utils/
├── features/
│   ├── deals/
│   │   ├── data/               # DealRepository, DealDto, Hive adapters
│   │   ├── domain/             # Deal model (Freezed), ScraperConfig
│   │   └── presentation/       # FeedPage, DealCard, SearchDelegate
│   ├── alerts/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── settings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── currency/
│       ├── data/               # ECB/ER-API client, CurrencyRepository
│       ├── domain/             # ExchangeRates model
│       └── providers/
├── services/
│   ├── scraper_service.dart
│   ├── alert_evaluation_service.dart
│   └── background_refresh_service.dart
├── providers/                  # Cross-feature Riverpod providers
└── widgets/
    ├── adaptive_scaffold.dart
    └── shared/
```

---

## Implementation Plan

### Phase 1 — Foundation (current)
- [x] Repository & README
- [ ] `flutter create .` scaffold
- [ ] Directory structure
- [ ] `pubspec.yaml` dependencies (Riverpod, HTTP, HTML parser, Hive, Freezed)
- [ ] Verify clean web (WASM) compile

### Phase 2 — Core Data Layer
- [ ] Freezed models: `Deal`, `PriceAlert`, `AppSettings`, `ExchangeRates`, `ScraperConfig`
- [ ] Hive adapters & repository implementations
- [ ] Currency service + ECB client + 6-hour cache

### Phase 3 — Scraper Service
- [ ] `ScraperService` with configurable CSS selectors
- [ ] Platform switch: direct HTTP (mobile) vs BFF proxy (web)
- [ ] Price normalisation + EUR base conversion

### Phase 4 — Riverpod Providers
- [ ] `dealFeedProvider`, `alertsProvider`, `currencyProvider`, `settingsProvider`
- [ ] `build_runner` codegen wired up

### Phase 5 — Adaptive UI Shell
- [ ] `AdaptiveScaffold` with `NavigationRail` / `NavigationBar` toggle
- [ ] Feed page with `DealCard` skeleton
- [ ] Alerts page, Settings page stubs

### Phase 6 — Alerts & Notifications
- [ ] `AlertEvaluationService`
- [ ] `flutter_local_notifications` (mobile)
- [ ] Web Notifications API interop

### Phase 7 — Polish & Background Refresh
- [ ] `workmanager` background tasks (mobile)
- [ ] Web polling / SSE
- [ ] Error states, empty states, loading skeletons

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation (Freezed + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run on Chrome (WASM)
flutter run -d chrome --web-renderer canvaskit

# Run on iOS simulator / Android emulator
flutter run

# Build release web (WASM)
flutter build web --wasm
```
