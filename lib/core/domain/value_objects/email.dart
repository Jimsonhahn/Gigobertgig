import 'package:flutter/foundation.dart';

@immutable
class Email {
  final String value;

  const Email._(this.value);

  factory Email(String input) {
    if (!_isValidEmail(input)) {
      throw ArgumentError('Invalid email format: $input');
    }
    return Email._(input.toLowerCase());
  }

  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Email && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}