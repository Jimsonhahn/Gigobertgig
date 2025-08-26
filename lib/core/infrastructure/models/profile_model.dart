import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/value_objects/unique_id.dart';
import '../../domain/value_objects/location.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? bio;
  @JsonKey(name: 'location_lat')
  final double locationLat;
  @JsonKey(name: 'location_lng')
  final double locationLng;
  @JsonKey(name: 'location_address')
  final String locationAddress;
  @JsonKey(name: 'location_city')
  final String? locationCity;
  @JsonKey(name: 'location_postal_code')
  final String? locationPostalCode;
  @JsonKey(name: 'location_country')
  final String? locationCountry;
  @JsonKey(name: 'social_links')
  final Map<String, String> socialLinks;
  final bool verified;
  final double? rating;
  @JsonKey(name: 'rating_count')
  final int? ratingCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.locationLat,
    required this.locationLng,
    required this.locationAddress,
    this.locationCity,
    this.locationPostalCode,
    this.locationCountry,
    required this.socialLinks,
    required this.verified,
    this.rating,
    this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  Location get location => Location(
        latitude: locationLat,
        longitude: locationLng,
        address: locationAddress,
        city: locationCity,
        postalCode: locationPostalCode,
        country: locationCountry,
      );
}

@JsonSerializable()
class ArtistProfileModel extends ProfileModel {
  @JsonKey(name: 'artist_name')
  final String artistName;
  final List<String> genres;
  @JsonKey(name: 'price_min')
  final double priceMin;
  @JsonKey(name: 'price_max')
  final double priceMax;
  @JsonKey(name: 'price_currency')
  final String priceCurrency;
  @JsonKey(name: 'technical_requirements')
  final Map<String, dynamic> technicalRequirements;
  final List<String> instruments;
  @JsonKey(name: 'years_active')
  final int yearsActive;

  const ArtistProfileModel({
    required super.id,
    required super.userId,
    required super.displayName,
    super.avatarUrl,
    super.bio,
    required super.locationLat,
    required super.locationLng,
    required super.locationAddress,
    super.locationCity,
    super.locationPostalCode,
    super.locationCountry,
    required super.socialLinks,
    required super.verified,
    super.rating,
    super.ratingCount,
    required super.createdAt,
    required super.updatedAt,
    required this.artistName,
    required this.genres,
    required this.priceMin,
    required this.priceMax,
    this.priceCurrency = 'EUR',
    required this.technicalRequirements,
    required this.instruments,
    required this.yearsActive,
  });

  factory ArtistProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ArtistProfileModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistProfileModelToJson(this);

  ArtistProfile toDomain() {
    return ArtistProfile(
      id: UniqueId.fromString(id),
      userId: UniqueId.fromString(userId),
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      location: location,
      socialLinks: socialLinks,
      verified: verified,
      rating: rating,
      ratingCount: ratingCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      artistName: artistName,
      genres: genres,
      priceRange: PriceRange(
        minPrice: priceMin,
        maxPrice: priceMax,
        currency: priceCurrency,
      ),
      technicalRequirements: _mapToTechnicalRequirements(technicalRequirements),
      mediaGallery: const MediaGallery(items: []), // TODO: Implement media mapping
      instruments: instruments,
      yearsActive: yearsActive,
    );
  }

  factory ArtistProfileModel.fromDomain(ArtistProfile profile) {
    return ArtistProfileModel(
      id: profile.id.value,
      userId: profile.userId.value,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      bio: profile.bio,
      locationLat: profile.location.latitude,
      locationLng: profile.location.longitude,
      locationAddress: profile.location.address,
      locationCity: profile.location.city,
      locationPostalCode: profile.location.postalCode,
      locationCountry: profile.location.country,
      socialLinks: profile.socialLinks,
      verified: profile.verified,
      rating: profile.rating,
      ratingCount: profile.ratingCount,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      artistName: profile.artistName,
      genres: profile.genres,
      priceMin: profile.priceRange.minPrice,
      priceMax: profile.priceRange.maxPrice,
      priceCurrency: profile.priceRange.currency,
      technicalRequirements: _technicalRequirementsToMap(profile.technicalRequirements),
      instruments: profile.instruments,
      yearsActive: profile.yearsActive,
    );
  }

  static TechnicalRequirements _mapToTechnicalRequirements(Map<String, dynamic> map) {
    return TechnicalRequirements(
      needsPA: map['needs_pa'] ?? false,
      needsLighting: map['needs_lighting'] ?? false,
      needsBackline: map['needs_backline'] ?? false,
      powerOutlets: map['power_outlets'] ?? 0,
      stageMinSize: map['stage_min_size'] ?? 0,
      additionalRequirements: map['additional_requirements'],
    );
  }

  static Map<String, dynamic> _technicalRequirementsToMap(TechnicalRequirements requirements) {
    return {
      'needs_pa': requirements.needsPA,
      'needs_lighting': requirements.needsLighting,
      'needs_backline': requirements.needsBackline,
      'power_outlets': requirements.powerOutlets,
      'stage_min_size': requirements.stageMinSize,
      'additional_requirements': requirements.additionalRequirements,
    };
  }
}