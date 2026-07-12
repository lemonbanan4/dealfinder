import 'dart:async';
import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';
import 'package:dealfinder_pro/features/auth/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

/// A mock of the [Auth] notifier for use in tests.
class MockAuth extends Auth with Mock {
  final AsyncValue<User?> _authState;

  MockAuth([this._authState = const AsyncValue.data(null)]);

  @override
  FutureOr<User?> build() {
    if (_authState is AsyncLoading) {
      // Simulate a loading state by returning a future that doesn't complete
      return Completer<User?>().future;
    }
    if (_authState is AsyncError) {
      final err = (_authState as AsyncError).error;
      throw err;
    }
    return _authState.value;
  }
}

/// A mock of the [User] model.
class MockUser extends Mock implements User {}
