import '../entities/user_profile.dart';
import '../value_objects/unique_id.dart';
import '../value_objects/location.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfileById(UniqueId id);
  Future<UserProfile?> getProfileByUserId(UniqueId userId);
  Future<ArtistProfile> createArtistProfile(ArtistProfile profile);
  Future<VenueProfile> createVenueProfile(VenueProfile profile);
  Future<OrganizerProfile> createOrganizerProfile(OrganizerProfile profile);
  Future<UserProfile> updateProfile(UserProfile profile);
  Future<void> deleteProfile(UniqueId id);
  
  Future<List<ArtistProfile>> searchArtists({
    String? query,
    List<String>? genres,
    Location? nearLocation,
    double? radiusKm,
    PriceRange? priceRange,
    DateTime? availableFrom,
    DateTime? availableTo,
    int? limit,
    int? offset,
  });
  
  Future<List<VenueProfile>> searchVenues({
    String? query,
    Location? nearLocation,
    double? radiusKm,
    int? minCapacity,
    int? maxCapacity,
    List<String>? amenities,
    int? limit,
    int? offset,
  });
  
  Future<List<OrganizerProfile>> getTopOrganizers({
    int limit = 10,
  });
  
  Future<void> updateRating(UniqueId profileId, double newRating, int newCount);
  Future<void> verifyProfile(UniqueId profileId);
  
  Stream<UserProfile?> watchProfile(UniqueId id);
}