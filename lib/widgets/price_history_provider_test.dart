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
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object? value) => this;

  @override
  PostgrestFilterBuilder<PostgrestList> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) =>
      this;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

void main() {
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

      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => fakeFilterBuilder);

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

    test('priceHistoryProvider throws an exception on Supabase error', () async {
      final exception = Exception('Network error');
      final fakeFilterBuilder = FakePostgrestFilterBuilder(
        Future.value([]).then<PostgrestList>((_) => throw exception),
      );

      when(() => mockSupabaseClient.from(any())).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => fakeFilterBuilder);

      container = ProviderContainer(
        overrides: [supabaseProvider.overrideWithValue(mockSupabaseClient)],
      );

      expect(
        container.read(priceHistoryProviderProvider('product-1').future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
