import 'package:flutter/foundation.dart';

@immutable
class User {
  const User({
    required this.id,
    this.email,
    this.emailVerified = true,
    this.displayName,
    this.photoURL,
    this.providerData = const [],
  });
  final String id;
  final String? email;
  final bool emailVerified;
  final String? displayName;
  final String? photoURL;
  final List<dynamic> providerData;

  String get uid => id;
}
