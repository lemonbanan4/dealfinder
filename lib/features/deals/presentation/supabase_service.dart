import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A provider that creates and exposes the Supabase client.
final supabaseProvider = Provider<SupabaseClient>((ref) {
  // It's good practice to throw an error if the client isn't initialized.
  // This helps catch setup issues early.
  try {
    return Supabase.instance.client;
  } catch (e) {
    // This will happen if Supabase.initialize() hasn't been called.
    throw Exception(
      'Supabase client is not initialized. Make sure to call Supabase.initialize() in your main() function.',
    );
  }
});
