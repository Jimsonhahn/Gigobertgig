import '../entities/event.dart';
import '../value_objects/unique_id.dart';
import '../value_objects/location.dart';

abstract class EventRepository {
  Future<Event?> getEventById(UniqueId id);
  Future<Event> createEvent(Event event);
  Future<Event> updateEvent(Event event);
  Future<void> cancelEvent(UniqueId id, String reason);
  Future<void> deleteEvent(UniqueId id);
  
  Future<List<Event>> getEventsByOrganizer(UniqueId organizerId, {
    EventStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  Future<List<Event>> getEventsByVenue(UniqueId venueId, {
    EventStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  Future<List<Event>> searchEvents({
    String? query,
    EventType? type,
    Location? nearLocation,
    double? radiusKm,
    DateTime? fromDate,
    DateTime? toDate,
    double? maxPrice,
    List<String>? tags,
    int? limit,
    int? offset,
  });
  
  Future<List<Event>> getTrendingEvents({
    int limit = 20,
    Location? nearLocation,
  });
  
  Future<List<Event>> getRecommendedEvents({
    required UniqueId userId,
    int limit = 20,
  });
  
  Future<Event> updateSlot(UniqueId eventId, EventSlot slot);
  Future<Event> bookSlot(
    UniqueId eventId,
    UniqueId slotId,
    UniqueId bookingId,
    String artistName,
    double agreedPrice,
  );
  
  Future<void> updateTicketSales(UniqueId eventId, int soldCount);
  Future<void> publishEvent(UniqueId eventId);
  Future<void> unpublishEvent(UniqueId eventId);
  
  Future<Map<String, dynamic>> getEventAnalytics(UniqueId eventId);
  
  Stream<Event?> watchEvent(UniqueId id);
  Stream<List<Event>> watchUpcomingEvents({Location? nearLocation});
}