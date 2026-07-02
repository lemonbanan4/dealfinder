import 'package:flutter/foundation.dart';

@immutable
class User {
  const User({required this.id, this.email});
  final String id;
  final String? email;
}
