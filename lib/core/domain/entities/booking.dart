import 'package:flutter/foundation.dart';
import '../value_objects/unique_id.dart';

enum BookingStatus {
  pending,
  negotiating,
  confirmed,
  cancelled,
  completed,
  rejected,
}

enum NegotiationType {
  priceChange,
  timeChange,
  venueChange,
  generalTerms,
}

enum NegotiationStatus {
  proposed,
  accepted,
  rejected,
  countered,
}

@immutable
class Booking {
  final UniqueId id;
  final UniqueId eventId;
  final UniqueId artistId;
  final UniqueId venueId;
  final UniqueId organizerId;
  final BookingStatus status;
  final TimeSlot requestedSlot;
  final TimeSlot? confirmedSlot;
  final PriceAgreement? priceAgreement;
  final List<Negotiation> negotiations;
  final String? contractUrl;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.eventId,
    required this.artistId,
    required this.venueId,
    required this.organizerId,
    required this.status,
    required this.requestedSlot,
    this.confirmedSlot,
    this.priceAgreement,
    required this.negotiations,
    this.contractUrl,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == BookingStatus.pending;
  bool get isNegotiating => status == BookingStatus.negotiating;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isRejected => status == BookingStatus.rejected;
  bool get isActive => !isCancelled && !isCompleted && !isRejected;

  Negotiation? get latestNegotiation =>
      negotiations.isEmpty ? null : negotiations.last;

  double calculateCancellationFee(DateTime cancellationDate) {
    if (confirmedSlot == null || priceAgreement == null) return 0;

    final daysUntilEvent = confirmedSlot!.startDateTime.difference(cancellationDate).inDays;
    
    if (daysUntilEvent >= 30) return 0;
    if (daysUntilEvent >= 14) return priceAgreement!.finalAmount * 0.25;
    if (daysUntilEvent >= 7) return priceAgreement!.finalAmount * 0.50;
    return priceAgreement!.finalAmount;
  }

  Booking copyWith({
    UniqueId? id,
    UniqueId? eventId,
    UniqueId? artistId,
    UniqueId? venueId,
    UniqueId? organizerId,
    BookingStatus? status,
    TimeSlot? requestedSlot,
    TimeSlot? confirmedSlot,
    PriceAgreement? priceAgreement,
    List<Negotiation>? negotiations,
    String? contractUrl,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      artistId: artistId ?? this.artistId,
      venueId: venueId ?? this.venueId,
      organizerId: organizerId ?? this.organizerId,
      status: status ?? this.status,
      requestedSlot: requestedSlot ?? this.requestedSlot,
      confirmedSlot: confirmedSlot ?? this.confirmedSlot,
      priceAgreement: priceAgreement ?? this.priceAgreement,
      negotiations: negotiations ?? this.negotiations,
      contractUrl: contractUrl ?? this.contractUrl,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@immutable
class TimeSlot {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String timezone;

  const TimeSlot({
    required this.startDateTime,
    required this.endDateTime,
    this.timezone = 'Europe/Berlin',
  });

  Duration get duration => endDateTime.difference(startDateTime);
  
  bool overlaps(TimeSlot other) {
    return startDateTime.isBefore(other.endDateTime) &&
           endDateTime.isAfter(other.startDateTime);
  }

  bool contains(DateTime dateTime) {
    return dateTime.isAfter(startDateTime) && dateTime.isBefore(endDateTime);
  }
}

@immutable
class PriceAgreement {
  final double requestedAmount;
  final double finalAmount;
  final String currency;
  final PaymentTerms paymentTerms;
  final List<AdditionalCost> additionalCosts;

  const PriceAgreement({
    required this.requestedAmount,
    required this.finalAmount,
    this.currency = 'EUR',
    required this.paymentTerms,
    this.additionalCosts = const [],
  });

  double get totalAmount => 
      finalAmount + additionalCosts.fold(0, (sum, cost) => sum + cost.amount);
}

@immutable
class PaymentTerms {
  final int depositPercentage;
  final int daysBeforeEventForDeposit;
  final int daysAfterEventForFullPayment;
  final bool includesVAT;

  const PaymentTerms({
    required this.depositPercentage,
    required this.daysBeforeEventForDeposit,
    required this.daysAfterEventForFullPayment,
    required this.includesVAT,
  });
}

@immutable
class AdditionalCost {
  final String description;
  final double amount;
  final bool isOptional;

  const AdditionalCost({
    required this.description,
    required this.amount,
    this.isOptional = false,
  });
}

@immutable
class Negotiation {
  final UniqueId id;
  final UniqueId bookingId;
  final UniqueId proposedBy;
  final NegotiationType type;
  final NegotiationProposal proposal;
  final NegotiationStatus status;
  final String? message;
  final DateTime createdAt;

  const Negotiation({
    required this.id,
    required this.bookingId,
    required this.proposedBy,
    required this.type,
    required this.proposal,
    required this.status,
    this.message,
    required this.createdAt,
  });
}

@immutable
abstract class NegotiationProposal {
  const NegotiationProposal();
}

@immutable
class PriceChangeProposal extends NegotiationProposal {
  final double newAmount;
  final String reason;

  const PriceChangeProposal({
    required this.newAmount,
    required this.reason,
  });
}

@immutable
class TimeChangeProposal extends NegotiationProposal {
  final TimeSlot newTimeSlot;
  final String reason;

  const TimeChangeProposal({
    required this.newTimeSlot,
    required this.reason,
  });
}

@immutable
class VenueChangeProposal extends NegotiationProposal {
  final UniqueId newVenueId;
  final String venueName;
  final String reason;

  const VenueChangeProposal({
    required this.newVenueId,
    required this.venueName,
    required this.reason,
  });
}