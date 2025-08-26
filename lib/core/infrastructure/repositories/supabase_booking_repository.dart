import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/value_objects/unique_id.dart';
import '../models/booking_model.dart';

class SupabaseBookingRepository implements BookingRepository {
  final SupabaseClient _client;

  const SupabaseBookingRepository(this._client);

  @override
  Future<Booking?> getBookingById(UniqueId id) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            events(*),
            artist_profiles(*),
            venue_profiles(*),
            negotiations(*)
          ''')
          .eq('id', id.value)
          .maybeSingle();

      if (response == null) return null;

      return BookingModel.fromJson(response).toDomain();
    } catch (e) {
      throw RepositoryException('Failed to get booking: $e');
    }
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    try {
      final bookingModel = BookingModel.fromDomain(booking);
      final response = await _client
          .from('bookings')
          .insert(bookingModel.toJson())
          .select('''
            *,
            events(*),
            artist_profiles(*),
            venue_profiles(*),
            negotiations(*)
          ''')
          .single();

      return BookingModel.fromJson(response).toDomain();
    } catch (e) {
      throw RepositoryException('Failed to create booking: $e');
    }
  }

  @override
  Future<Booking> updateBooking(Booking booking) async {
    try {
      final bookingModel = BookingModel.fromDomain(booking.copyWith(
        updatedAt: DateTime.now(),
      ));

      final response = await _client
          .from('bookings')
          .update(bookingModel.toJson())
          .eq('id', booking.id.value)
          .select('''
            *,
            events(*),
            artist_profiles(*),
            venue_profiles(*),
            negotiations(*)
          ''')
          .single();

      return BookingModel.fromJson(response).toDomain();
    } catch (e) {
      throw RepositoryException('Failed to update booking: $e');
    }
  }

  @override
  Future<void> cancelBooking(UniqueId id, String reason) async {
    try {
      await _client
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id.value);
    } catch (e) {
      throw RepositoryException('Failed to cancel booking: $e');
    }
  }

  @override
  Future<List<Booking>> getBookingsByArtist(
    UniqueId artistId, {
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _client
          .from('bookings')
          .select('''
            *,
            events(*),
            artist_profiles(*),
            venue_profiles(*),
            negotiations(*)
          ''')
          .eq('artist_id', artistId.value);

      if (status != null) {
        query = query.eq('status', _statusToString(status));
      }

      if (fromDate != null) {
        query = query.gte('requested_start', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('requested_start', toDate.toIso8601String());
      }

      final response = await query.order('requested_start');

      return response
          .map<Booking>((json) => BookingModel.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to get artist bookings: $e');
    }
  }

  @override
  Future<List<Booking>> getBookingsByVenue(
    UniqueId venueId, {
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _client
          .from('bookings')
          .select('''
            *,
            events(*),
            artist_profiles(*),
            venue_profiles(*),
            negotiations(*)
          ''')
          .eq('venue_id', venueId.value);

      if (status != null) {
        query = query.eq('status', _statusToString(status));
      }

      if (fromDate != null) {
        query = query.gte('requested_start', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('requested_start', toDate.toIso8601String());
      }

      final response = await query.order('requested_start');

      return response
          .map<Booking>((json) => BookingModel.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to get venue bookings: $e');
    }
  }

  @override
  Future<List<Booking>> getBookingsByOrganizer(
    UniqueId organizerId, {
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _client
          .from('bookings')
          .select('''
            *,
            events(*),
            artist_profiles(*),
            venue_profiles(*),
            negotiations(*)
          ''')
          .eq('organizer_id', organizerId.value);

      if (status != null) {
        query = query.eq('status', _statusToString(status));
      }

      if (fromDate != null) {
        query = query.gte('requested_start', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('requested_start', toDate.toIso8601String());
      }

      final response = await query.order('requested_start');

      return response
          .map<Booking>((json) => BookingModel.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to get organizer bookings: $e');
    }
  }

  @override
  Future<List<Booking>> getBookingsByEvent(UniqueId eventId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('''
            *,
            events(*),
            artist_profiles(*),
            venue_profiles(*),
            negotiations(*)
          ''')
          .eq('event_id', eventId.value)
          .order('requested_start');

      return response
          .map<Booking>((json) => BookingModel.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to get event bookings: $e');
    }
  }

  @override
  Future<bool> checkAvailability({
    required UniqueId artistId,
    required TimeSlot timeSlot,
  }) async {
    try {
      final conflicts = await getConflictingBookings(
        artistId: artistId,
        timeSlot: timeSlot,
      );

      return conflicts.isEmpty;
    } catch (e) {
      throw RepositoryException('Failed to check availability: $e');
    }
  }

  @override
  Future<List<Booking>> getConflictingBookings({
    required UniqueId artistId,
    required TimeSlot timeSlot,
  }) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*')
          .eq('artist_id', artistId.value)
          .in_('status', ['confirmed', 'negotiating'])
          .lt('requested_start', timeSlot.endDateTime.toIso8601String())
          .gt('requested_end', timeSlot.startDateTime.toIso8601String());

      return response
          .map<Booking>((json) => BookingModel.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to get conflicting bookings: $e');
    }
  }

  @override
  Future<Booking> addNegotiation(UniqueId bookingId, Negotiation negotiation) async {
    // Implementation would add negotiation to separate table
    // and return updated booking
    throw UnimplementedError('addNegotiation not yet implemented');
  }

  @override
  Future<Booking> updateNegotiationStatus(
    UniqueId bookingId,
    UniqueId negotiationId,
    NegotiationStatus status,
  ) async {
    // Implementation would update negotiation status
    throw UnimplementedError('updateNegotiationStatus not yet implemented');
  }

  @override
  Future<void> generateContract(UniqueId bookingId) async {
    // Implementation would generate PDF contract
    throw UnimplementedError('generateContract not yet implemented');
  }

  @override
  Future<String?> getContractUrl(UniqueId bookingId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('contract_url')
          .eq('id', bookingId.value)
          .maybeSingle();

      return response?['contract_url'] as String?;
    } catch (e) {
      throw RepositoryException('Failed to get contract URL: $e');
    }
  }

  @override
  Future<List<Booking>> getUpcomingBookings(UniqueId userId, {int days = 30}) async {
    try {
      final endDate = DateTime.now().add(Duration(days: days));

      final response = await _client
          .from('bookings')
          .select('''
            *,
            events(*),
            artist_profiles(*),
            venue_profiles(*)
          ''')
          .or('artist_id.eq.$userId,organizer_id.eq.$userId')
          .eq('status', 'confirmed')
          .gte('requested_start', DateTime.now().toIso8601String())
          .lte('requested_start', endDate.toIso8601String())
          .order('requested_start');

      return response
          .map<Booking>((json) => BookingModel.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to get upcoming bookings: $e');
    }
  }

  @override
  Future<Map<String, int>> getBookingStatistics(UniqueId userId) async {
    try {
      final response = await _client.rpc('get_booking_stats', params: {
        'user_id': userId.value,
      });

      return Map<String, int>.from(response ?? {});
    } catch (e) {
      throw RepositoryException('Failed to get booking statistics: $e');
    }
  }

  @override
  Stream<Booking?> watchBooking(UniqueId id) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('id', id.value)
        .map((data) {
          if (data.isEmpty) return null;
          return BookingModel.fromJson(data.first).toDomain();
        });
  }

  @override
  Stream<List<Booking>> watchUserBookings(UniqueId userId) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .or('artist_id.eq.$userId,organizer_id.eq.$userId')
        .map((data) => data
            .map<Booking>((json) => BookingModel.fromJson(json).toDomain())
            .toList());
  }

  String _statusToString(BookingStatus status) {
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
}

class RepositoryException implements Exception {
  final String message;
  final dynamic cause;

  const RepositoryException(this.message, [this.cause]);

  @override
  String toString() => 'RepositoryException: $message';
}