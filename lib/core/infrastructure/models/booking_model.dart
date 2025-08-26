import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/booking.dart';
import '../../domain/value_objects/unique_id.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel {
  final String id;
  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'artist_id')
  final String artistId;
  @JsonKey(name: 'venue_id')
  final String venueId;
  @JsonKey(name: 'organizer_id')
  final String organizerId;
  final String status;
  @JsonKey(name: 'requested_start')
  final DateTime requestedStart;
  @JsonKey(name: 'requested_end')
  final DateTime requestedEnd;
  @JsonKey(name: 'confirmed_start')
  final DateTime? confirmedStart;
  @JsonKey(name: 'confirmed_end')
  final DateTime? confirmedEnd;
  @JsonKey(name: 'agreed_price')
  final double? agreedPrice;
  final String? currency;
  @JsonKey(name: 'contract_url')
  final String? contractUrl;
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.eventId,
    required this.artistId,
    required this.venueId,
    required this.organizerId,
    required this.status,
    required this.requestedStart,
    required this.requestedEnd,
    this.confirmedStart,
    this.confirmedEnd,
    this.agreedPrice,
    this.currency,
    this.contractUrl,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  factory BookingModel.fromDomain(Booking booking) {
    return BookingModel(
      id: booking.id.value,
      eventId: booking.eventId.value,
      artistId: booking.artistId.value,
      venueId: booking.venueId.value,
      organizerId: booking.organizerId.value,
      status: _statusToString(booking.status),
      requestedStart: booking.requestedSlot.startDateTime,
      requestedEnd: booking.requestedSlot.endDateTime,
      confirmedStart: booking.confirmedSlot?.startDateTime,
      confirmedEnd: booking.confirmedSlot?.endDateTime,
      agreedPrice: booking.priceAgreement?.finalAmount,
      currency: booking.priceAgreement?.currency ?? 'EUR',
      contractUrl: booking.contractUrl,
      cancellationReason: booking.cancellationReason,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
  }

  Booking toDomain() {
    return Booking(
      id: UniqueId.fromString(id),
      eventId: UniqueId.fromString(eventId),
      artistId: UniqueId.fromString(artistId),
      venueId: UniqueId.fromString(venueId),
      organizerId: UniqueId.fromString(organizerId),
      status: _stringToStatus(status),
      requestedSlot: TimeSlot(
        startDateTime: requestedStart,
        endDateTime: requestedEnd,
      ),
      confirmedSlot: confirmedStart != null && confirmedEnd != null
          ? TimeSlot(
              startDateTime: confirmedStart!,
              endDateTime: confirmedEnd!,
            )
          : null,
      priceAgreement: agreedPrice != null
          ? PriceAgreement(
              requestedAmount: agreedPrice!,
              finalAmount: agreedPrice!,
              currency: currency ?? 'EUR',
              paymentTerms: const PaymentTerms(
                depositPercentage: 30,
                daysBeforeEventForDeposit: 14,
                daysAfterEventForFullPayment: 7,
                includesVAT: true,
              ),
            )
          : null,
      negotiations: [], // TODO: Load from separate table
      contractUrl: contractUrl,
      cancellationReason: cancellationReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.negotiating:
        return 'negotiating';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.rejected:
        return 'rejected';
    }
  }

  static BookingStatus _stringToStatus(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'negotiating':
        return BookingStatus.negotiating;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        throw ArgumentError('Unknown booking status: $status');
    }
  }
}