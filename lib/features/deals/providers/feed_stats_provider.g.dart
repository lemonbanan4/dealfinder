// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Aggregate counts (see `/api/stats` in api.py) driving the feed's live
/// status banner — how many products have a lower price than 24h ago, and
/// how many rows the most recent scraper run touched.

@ProviderFor(feedStats)
final feedStatsProvider = FeedStatsProvider._();

/// Aggregate counts (see `/api/stats` in api.py) driving the feed's live
/// status banner — how many products have a lower price than 24h ago, and
/// how many rows the most recent scraper run touched.

final class FeedStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedStats>,
          FeedStats,
          FutureOr<FeedStats>
        >
    with $FutureModifier<FeedStats>, $FutureProvider<FeedStats> {
  /// Aggregate counts (see `/api/stats` in api.py) driving the feed's live
  /// status banner — how many products have a lower price than 24h ago, and
  /// how many rows the most recent scraper run touched.
  FeedStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedStatsHash();

  @$internal
  @override
  $FutureProviderElement<FeedStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<FeedStats> create(Ref ref) {
    return feedStats(ref);
  }
}

String _$feedStatsHash() => r'2b1bbd5aaee7fa16bc8a063628354bd3550b4116';
