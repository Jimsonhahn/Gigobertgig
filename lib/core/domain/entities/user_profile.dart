import 'package:flutter/foundation.dart';
import '../value_objects/unique_id.dart';
import '../value_objects/location.dart';

@immutable
abstract class UserProfile {
  final UniqueId id;
  final UniqueId userId;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final Location location;
  final Map<String, String> socialLinks;
  final bool verified;
  final double? rating;
  final int? ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.location,
    required this.socialLinks,
    required this.verified,
    this.rating,
    this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
  });
}

@immutable
class ArtistProfile extends UserProfile {
  final String artistName;
  final List<String> genres;
  final PriceRange priceRange;
  final TechnicalRequirements technicalRequirements;
  final MediaGallery mediaGallery;
  final List<String> instruments;
  final int yearsActive;

  const ArtistProfile({
    required super.id,
    required super.userId,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    required super.location,
    required super.socialLinks,
    required super.verified,
    super.rating,
    super.ratingCount,
    required super.createdAt,
    required super.updatedAt,
    required this.artistName,
    required this.genres,
    required this.priceRange,
    required this.technicalRequirements,
    required this.mediaGallery,
    required this.instruments,
    required this.yearsActive,
  });
}

@immutable
class VenueProfile extends UserProfile {
  final String venueName;
  final int capacityMin;
  final int capacityMax;
  final List<VenueSpace> spaces;
  final List<String> amenities;
  final String? houseRules;
  final OperatingHours operatingHours;
  final List<String> eventTypes;

  const VenueProfile({
    required super.id,
    required super.userId,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    required super.location,
    required super.socialLinks,
    required super.verified,
    super.rating,
    super.ratingCount,
    required super.createdAt,
    required super.updatedAt,
    required this.venueName,
    required this.capacityMin,
    required this.capacityMax,
    required this.spaces,
    required this.amenities,
    this.houseRules,
    required this.operatingHours,
    required this.eventTypes,
  });
}

@immutable
class OrganizerProfile extends UserProfile {
  final String organizerName;
  final String? companyName;
  final List<String> eventTypes;
  final int eventsOrganized;
  final bool professionalOrganizer;

  const OrganizerProfile({
    required super.id,
    required super.userId,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    required super.location,
    required super.socialLinks,
    required super.verified,
    super.rating,
    super.ratingCount,
    required super.createdAt,
    required super.updatedAt,
    required this.organizerName,
    this.companyName,
    required this.eventTypes,
    required this.eventsOrganized,
    required this.professionalOrganizer,
  });
}

@immutable
class PriceRange {
  final double minPrice;
  final double maxPrice;
  final String currency;

  const PriceRange({
    required this.minPrice,
    required this.maxPrice,
    this.currency = 'EUR',
  });

  String get displayText => '$currency ${minPrice.toStringAsFixed(0)}-${maxPrice.toStringAsFixed(0)}';
}

@immutable
class TechnicalRequirements {
  final bool needsPA;
  final bool needsLighting;
  final bool needsBackline;
  final int powerOutlets;
  final int stageMinSize;
  final String? additionalRequirements;

  const TechnicalRequirements({
    required this.needsPA,
    required this.needsLighting,
    required this.needsBackline,
    required this.powerOutlets,
    required this.stageMinSize,
    this.additionalRequirements,
  });
}

@immutable
class MediaGallery {
  final List<MediaItem> items;

  const MediaGallery({required this.items});

  List<MediaItem> get images => items.where((item) => item.type == MediaType.image).toList();
  List<MediaItem> get videos => items.where((item) => item.type == MediaType.video).toList();
  List<MediaItem> get audio => items.where((item) => item.type == MediaType.audio).toList();
}

enum MediaType { image, video, audio }

@immutable
class MediaItem {
  final UniqueId id;
  final String url;
  final MediaType type;
  final String? thumbnailUrl;
  final String? caption;
  final int orderIndex;

  const MediaItem({
    required this.id,
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.caption,
    required this.orderIndex,
  });
}

@immutable
class VenueSpace {
  final UniqueId id;
  final String name;
  final int capacity;
  final double size;
  final Map<String, bool> equipment;
  final double hourlyRate;
  final List<String> suitableFor;

  const VenueSpace({
    required this.id,
    required this.name,
    required this.capacity,
    required this.size,
    required this.equipment,
    required this.hourlyRate,
    required this.suitableFor,
  });
}

@immutable
class OperatingHours {
  final Map<int, DaySchedule> schedule;

  const OperatingHours({required this.schedule});

  bool isOpenAt(DateTime dateTime) {
    final daySchedule = schedule[dateTime.weekday];
    if (daySchedule == null || !daySchedule.isOpen) return false;
    
    final timeInMinutes = dateTime.hour * 60 + dateTime.minute;
    return timeInMinutes >= daySchedule.openTime && timeInMinutes <= daySchedule.closeTime;
  }
}

@immutable
class DaySchedule {
  final bool isOpen;
  final int openTime; // Minutes from midnight
  final int closeTime; // Minutes from midnight

  const DaySchedule({
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });
}