import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:dealfinder_pro/features/deals/providers/deals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks for Supabase dependencies
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  FakePostgrestFilterBuilder(this._future);
  final Future<PostgrestList> _future;

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object? value) =>
      this;

  @override
  PostgrestFilterBuilder<PostgrestList> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) => this;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }

  @override
  Future<PostgrestList> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) {
    return _future.catchError(onError, test: test);
  }

  @override
  Future<PostgrestList> whenComplete(FutureOr<void> Function() action) {
    return _future.whenComplete(action);
  }

  @override
  Stream<PostgrestList> asStream() {
    return _future.asStream();
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('http://fake.com'));
  });

  group('priceHistoryProvider', () {
    late ProviderContainer container;
    late MockSupabaseClient mockSupabaseClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
    });

    tearDown(() {
      try {
        container.dispose();
      } catch (_) {}
    });

    test('priceHistoryProvider returns a list of FlSpot on success', () async {
      final mockResponse = [
        {'price': 100.0, 'recorded_at': '2023-01-01T12:00:00Z'},
        {'price': 120.0, 'recorded_at': '2023-01-02T12:00:00Z'},
      ];
      final fakeFilterBuilder = FakePostgrestFilterBuilder(
        Future.value(PostgrestList.from(mockResponse)),
      );

      when(
        () => mockSupabaseClient.from(any()),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select(any()),
      ).thenAnswer((_) => fakeFilterBuilder);

      container = ProviderContainer(
        overrides: [supabaseProvider.overrideWithValue(mockSupabaseClient)],
      );

      final result = await container.read(
        priceHistoryProviderProvider('product-1').future,
      );

      expect(result, isA<List<FlSpot>>());
      expect(result.length, 2);
      expect(result.first.y, 100.0);
      expect(result.last.y, 120.0);
    });

    test(
      'priceHistoryProvider throws an exception on Supabase error',
      () async {
        final exception = Exception('Network error');
        final fakeFilterBuilder = FakePostgrestFilterBuilder(
          Future<PostgrestList>.error(exception),
        );

        when(
          () => mockSupabaseClient.from(any()),
        ).thenAnswer((_) => mockQueryBuilder);
        when(
          () => mockQueryBuilder.select(any()),
        ).thenAnswer((_) => fakeFilterBuilder);

        container = ProviderContainer(
          overrides: [supabaseProvider.overrideWithValue(mockSupabaseClient)],
        );

        // `container.read(provider.future)` races this (autoDispose)
        // provider's own error-handling against Riverpod's dispose
        // scheduling: reading `.future` creates and immediately closes a
        // transient subscription, which can schedule the provider's disposal
        // before the mocked error actually finishes propagating through the
        // build function — the provider then gets torn down mid-"loading"
        // and throws a StateError instead of the real exception. Watching the
        // AsyncValue directly via a real (held-open) listener sidesteps that
        // race entirely.
        final completer = Completer<Object>();
        final subscription = container.listen(
          priceHistoryProviderProvider('product-1'),
          (previous, next) {
            if (next.hasError && !completer.isCompleted) {
              completer.complete(next.error);
            }
          },
          fireImmediately: true,
        );

        final error = await completer.future.timeout(
          const Duration(seconds: 5),
        );
        expect(error, equals(exception));

        subscription.close();
      },
    );
  });
}
