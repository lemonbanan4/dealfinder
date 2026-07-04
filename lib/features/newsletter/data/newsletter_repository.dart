import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../deals/providers/deals_provider.dart' show supabaseProvider;

/// Writes newsletter signups to the `newsletter_subscribers` table.
///
/// Expected schema:
/// ```sql
/// create table if not exists newsletter_subscribers (
///   email text primary key,
///   subscribed_at timestamptz not null default now()
/// );
/// ```
class NewsletterRepository {
  NewsletterRepository(this._client);

  final SupabaseClient _client;

  /// Throws [PostgrestException] on failure, including a unique-violation
  /// when [email] is already subscribed — callers should surface that as a
  /// friendly "you're already signed up" message rather than a generic error.
  Future<void> subscribe(String email) async {
    await _client.from('newsletter_subscribers').insert({'email': email});
  }
}

final newsletterRepositoryProvider = Provider<NewsletterRepository>((ref) {
  return NewsletterRepository(ref.watch(supabaseProvider));
});
