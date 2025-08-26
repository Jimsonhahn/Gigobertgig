import '../entities/booking.dart';
import '../value_objects/unique_id.dart';

abstract class BookingRepository {
  Future<Booking?> getBookingById(UniqueId id);
  Future<Booking> createBooking(Booking booking);
  Future<Booking> updateBooking(Booking booking);
  Future<void> cancelBooking(UniqueId id, String reason);
  
  Future<List<Booking>> getBookingsByArtist(UniqueId artistId, {
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  Future<List<Booking>> getBookingsByVenue(UniqueId venueId, {
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  Future<List<Booking>> getBookingsByOrganizer(UniqueId organizerId, {
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  Future<List<Booking>> getBookingsByEvent(UniqueId eventId);
  
  Future<bool> checkAvailability({
    required UniqueId artistId,
    required TimeSlot timeSlot,
  });
  
  Future<List<Booking>> getConflictingBookings({
    required UniqueId artistId,
    required TimeSlot timeSlot,
  });
  
  Future<Booking> addNegotiation(UniqueId bookingId, Negotiation negotiation);
  Future<Booking> updateNegotiationStatus(
    UniqueId bookingId,
    UniqueId negotiationId,
    NegotiationStatus status,
  );
  
  Future<void> generateContract(UniqueId bookingId);
  Future<String?> getContractUrl(UniqueId bookingId);
  
  Future<List<Booking>> getUpcomingBookings(UniqueId userId, {int days = 30});
  Future<Map<String, int>> getBookingStatistics(UniqueId userId);
  
  Stream<Booking?> watchBooking(UniqueId id);
  Stream<List<Booking>> watchUserBookings(UniqueId userId);
}