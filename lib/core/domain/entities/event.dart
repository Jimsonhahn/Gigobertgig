import 'package:flutter/foundation.dart';
import '../value_objects/unique_id.dart';
import '../value_objects/location.dart';

enum EventType {
  concert,
  festival,
  clubNight,
  privateParty,
  corporate,
  wedding,
  openAir,
  showcase,
}

enum EventStatus {
  draft,
  published,
  soldOut,
  cancelled,
  completed,
}

enum SlotType {
  mainAct,
  supportAct,
  opener,
  headliner,
  djSet,
  livePerformance,
}

@immutable
class Event {
  final UniqueId id;
  final UniqueId organizerId;
  final UniqueId venueId;
  final String title;
  final String description;
  final EventType type;
  final EventStatus status;
  final DateTime date;
  final List<EventSlot> slots;
  final int expectedAttendance;
  final TicketInfo? ticketInfo;
  final List<String> tags;
  final EventMedia media;
  final Location location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.organizerId,
    required this.venueId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.date,
    required this.slots,
    required this.expectedAttendance,
    this.ticketInfo,
    required this.tags,
    required this.media,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPublished => status == EventStatus.published;
  bool get isDraft => status == EventStatus.draft;
  bool get isSoldOut => status == EventStatus.soldOut;
  bool get isCancelled => status == EventStatus.cancelled;
  bool get isCompleted => status == EventStatus.completed;
  bool get isUpcoming => date.isAfter(DateTime.now()) && !isCancelled;
  bool get isPast => date.isBefore(DateTime.now()) || isCompleted;

  List<EventSlot> get availableSlots =>
      slots.where((slot) => !slot.isBooked).toList();

  List<EventSlot> get bookedSlots =>
      slots.where((slot) => slot.isBooked).toList();

  Event copyWith({
    UniqueId? id,
    UniqueId? organizerId,
    UniqueId? venueId,
    String? title,
    String? description,
    EventType? type,
    EventStatus? status,
    DateTime? date,
    List<EventSlot>? slots,
    int? expectedAttendance,
    TicketInfo? ticketInfo,
    List<String>? tags,
    EventMedia? media,
    Location? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      venueId: venueId ?? this.venueId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      slots: slots ?? this.slots,
      expectedAttendance: expectedAttendance ?? this.expectedAttendance,
      ticketInfo: ticketInfo ?? this.ticketInfo,
      tags: tags ?? this.tags,
      media: media ?? this.media,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@immutable
class EventSlot {
  final UniqueId id;
  final UniqueId eventId;
  final DateTime startTime;
  final DateTime endTime;
  final SlotType slotType;
  final UniqueId? bookingId;
  final String? artistName;
  final double? agreedPrice;

  const EventSlot({
    required this.id,
    required this.eventId,
    required this.startTime,
    required this.endTime,
    required this.slotType,
    this.bookingId,
    this.artistName,
    this.agreedPrice,
  });

  bool get isBooked => bookingId != null;
  Duration get duration => endTime.difference(startTime);

  EventSlot copyWith({
    UniqueId? id,
    UniqueId? eventId,
    DateTime? startTime,
    DateTime? endTime,
    SlotType? slotType,
    UniqueId? bookingId,
    String? artistName,
    double? agreedPrice,
  }) {
    return EventSlot(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotType: slotType ?? this.slotType,
      bookingId: bookingId ?? this.bookingId,
      artistName: artistName ?? this.artistName,
      agreedPrice: agreedPrice ?? this.agreedPrice,
    );
  }
}

@immutable
class TicketInfo {
  final double price;
  final double? earlyBirdPrice;
  final int totalCapacity;
  final int soldCount;
  final String? ticketUrl;
  final DateTime? salesStartDate;
  final DateTime? salesEndDate;

  const TicketInfo({
    required this.price,
    this.earlyBirdPrice,
    required this.totalCapacity,
    required this.soldCount,
    this.ticketUrl,
    this.salesStartDate,
    this.salesEndDate,
  });

  int get availableTickets => totalCapacity - soldCount;
  bool get isSoldOut => availableTickets <= 0;
  double get soldPercentage => (soldCount / totalCapacity) * 100;

  bool get isEarlyBird {
    if (earlyBirdPrice == null || salesStartDate == null) return false;
    final now = DateTime.now();
    return now.isAfter(salesStartDate!) && 
           now.isBefore(salesStartDate!.add(const Duration(days: 14)));
  }

  double get currentPrice => isEarlyBird ? earlyBirdPrice! : price;
}

@immutable
class EventMedia {
  final String? coverImageUrl;
  final String? thumbnailUrl;
  final List<String> galleryImages;
  final String? promoVideoUrl;
  final Map<String, String> socialMediaLinks;

  const EventMedia({
    this.coverImageUrl,
    this.thumbnailUrl,
    this.galleryImages = const [],
    this.promoVideoUrl,
    this.socialMediaLinks = const {},
  });

  bool get hasMedia => 
      coverImageUrl != null || 
      galleryImages.isNotEmpty || 
      promoVideoUrl != null;
}