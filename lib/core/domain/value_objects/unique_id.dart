import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

@immutable
class UniqueId {
  final String value;

  const UniqueId._(this.value);

  factory UniqueId() {
    return UniqueId._(const Uuid().v4());
  }

  factory UniqueId.fromString(String id) {
    if (!_isValidUuid(id)) {
      throw ArgumentError('Invalid UUID format: $id');
    }
    return UniqueId._(id);
  }

  static bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(uuid);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniqueId && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}