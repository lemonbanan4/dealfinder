import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

/// A concise, human-readable message for an error caught from an async
/// action — use this instead of dumping `error.toString()` into a SnackBar.
/// Some exception types (Firestore/network failures, JS interop errors
/// surfaced through web plugins) stringify to a multi-line wall of text
/// that's unreadable in a SnackBar's cramped space.
String friendlyErrorMessage(Object error) {
  if (error is FirebaseException) {
    final message = error.message;
    return (message != null && message.trim().isNotEmpty)
        ? message
        : 'Something went wrong (${error.code}).';
  }
  if (error is PostgrestException) {
    return error.message;
  }

  // Fallback for plain Exceptions (this codebase's own explicit throws) and
  // anything else — take just the first line and cap the length.
  const maxLength = 140;
  final firstLine = error.toString().trim().split('\n').first;
  return firstLine.length > maxLength
      ? '${firstLine.substring(0, maxLength)}…'
      : firstLine;
}
