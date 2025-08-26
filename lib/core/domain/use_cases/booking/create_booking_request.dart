import '../../entities/booking.dart';
import '../../entities/event.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../value_objects/unique_id.dart';

class CreateBookingRequestParams {
  final UniqueId eventId;
  final UniqueId slotId;
  final UniqueId artistId;
  final UniqueId organizerId;
  final TimeSlot requestedSlot;
  final double proposedPrice;
  final String? message;

  const CreateBookingRequestParams({
    required this.eventId,
    required this.slotId,
    required this.artistId,
    required this.organizerId,
    required this.requestedSlot,
    required this.proposedPrice,
    this.message,
  });
}

class CreateBookingRequest {
  final BookingRepository _bookingRepository;
  final EventRepository _eventRepository;
  final ProfileRepository _profileRepository;

  const CreateBookingRequest(
    this._bookingRepository,
    this._eventRepository,
    this._profileRepository,
  );

  Future<Booking> call(CreateBookingRequestParams params) async {
    // Validate event exists and slot is available
    final event = await _eventRepository.getEventById(params.eventId);
    if (event == null) {
      throw EventNotFoundException('Event not found');
    }

    final slot = event.slots.firstWhere(
      (s) => s.id == params.slotId,
      orElse: () => throw SlotNotFoundException('Slot not found'),
    );

    if (slot.isBooked) {
      throw SlotAlreadyBookedException('This slot is already booked');
    }

    // Check artist availability
    final isAvailable = await _bookingRepository.checkAvailability(
      artistId: params.artistId,
      timeSlot: params.requestedSlot,
    );

    if (!isAvailable) {
      throw ArtistNotAvailableException('Artist is not available for this time');
    }

    // Check for conflicts
    final conflicts = await _bookingRepository.getConflictingBookings(
      artistId: params.artistId,
      timeSlot: params.requestedSlot,
    );

    if (conflicts.isNotEmpty) {
      throw BookingConflictException('Artist has conflicting bookings');
    }

    // Create booking
    final booking = Booking(
      id: UniqueId(),
      eventId: params.eventId,
      artistId: params.artistId,
      venueId: event.venueId,
      organizerId: params.organizerId,
      status: BookingStatus.pending,
      requestedSlot: params.requestedSlot,
      priceAgreement: PriceAgreement(
        requestedAmount: params.proposedPrice,
        finalAmount: params.proposedPrice,
        paymentTerms: PaymentTerms(
          depositPercentage: 30,
          daysBeforeEventForDeposit: 14,
          daysAfterEventForFullPayment: 7,
          includesVAT: true,
        ),
      ),
      negotiations: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Add initial negotiation if message provided
    if (params.message != null) {
      final negotiation = Negotiation(
        id: UniqueId(),
        bookingId: booking.id,
        proposedBy: params.organizerId,
        type: NegotiationType.generalTerms,
        proposal: InitialProposal(message: params.message!),
        status: NegotiationStatus.proposed,
        message: params.message,
        createdAt: DateTime.now(),
      );
      
      return await _bookingRepository.createBooking(
        booking.copyWith(negotiations: [negotiation]),
      );
    }

    return await _bookingRepository.createBooking(booking);
  }
}

class InitialProposal extends NegotiationProposal {
  final String message;
  const InitialProposal({required this.message});
}

// Exceptions
class EventNotFoundException implements Exception {
  final String message;
  const EventNotFoundException(this.message);
}

class SlotNotFoundException implements Exception {
  final String message;
  const SlotNotFoundException(this.message);
}

class SlotAlreadyBookedException implements Exception {
  final String message;
  const SlotAlreadyBookedException(this.message);
}

class ArtistNotAvailableException implements Exception {
  final String message;
  const ArtistNotAvailableException(this.message);
}

class BookingConflictException implements Exception {
  final String message;
  const BookingConflictException(this.message);
}