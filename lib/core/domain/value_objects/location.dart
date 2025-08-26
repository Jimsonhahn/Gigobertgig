import 'package:flutter/foundation.dart';
import 'dart:math' as math;

@immutable
class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String? city;
  final String? postalCode;
  final String? country;

  const Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
    this.postalCode,
    this.country,
  });

  factory Location.fromCoordinates({
    required double latitude,
    required double longitude,
    String address = '',
  }) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Invalid latitude: $latitude');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Invalid longitude: $longitude');
    }
    return Location(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  double distanceTo(Location other) {
    const double earthRadius = 6371; // kilometers
    final double latDiff = _toRadians(other.latitude - latitude);
    final double lonDiff = _toRadians(other.longitude - longitude);
    
    final double a = 
        math.sin(latDiff / 2) * math.sin(latDiff / 2) +
        math.cos(_toRadians(latitude)) * 
        math.cos(_toRadians(other.latitude)) *
        math.sin(lonDiff / 2) * math.sin(lonDiff / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => '$address ($latitude, $longitude)';
}