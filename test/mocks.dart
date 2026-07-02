import 'package:dealfinder_pro/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthNotifier extends StateNotifier<AsyncValue<User?>>
    with Mock
    implements AuthNotifier {
  MockAuthNotifier(super.state);
}
