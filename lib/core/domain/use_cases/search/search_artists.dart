import '../../entities/user_profile.dart';
import '../../repositories/profile_repository.dart';
import '../../value_objects/location.dart';

class SearchArtistsParams {
  final String? query;
  final List<String>? genres;
  final Location? location;
  final double? radiusKm;
  final PriceRange? priceRange;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final SortBy sortBy;
  final int page;
  final int pageSize;

  const SearchArtistsParams({
    this.query,
    this.genres,
    this.location,
    this.radiusKm,
    this.priceRange,
    this.availableFrom,
    this.availableTo,
    this.sortBy = SortBy.relevance,
    this.page = 1,
    this.pageSize = 20,
  });
}

enum SortBy {
  relevance,
  rating,
  distance,
  priceAsc,
  priceDesc,
  newest,
}

class SearchArtistsResult {
  final List<ArtistProfile> artists;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const SearchArtistsResult({
    required this.artists,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}

class SearchArtists {
  final ProfileRepository _profileRepository;

  const SearchArtists(this._profileRepository);

  Future<SearchArtistsResult> call(SearchArtistsParams params) async {
    // Validate parameters
    if (params.location != null && params.radiusKm == null) {
      throw ArgumentError('Radius must be specified when location is provided');
    }

    if (params.availableFrom != null && params.availableTo != null) {
      if (params.availableFrom!.isAfter(params.availableTo!)) {
        throw ArgumentError('availableFrom must be before availableTo');
      }
    }

    // Calculate offset
    final offset = (params.page - 1) * params.pageSize;

    // Search artists
    var artists = await _profileRepository.searchArtists(
      query: params.query,
      genres: params.genres,
      nearLocation: params.location,
      radiusKm: params.radiusKm,
      priceRange: params.priceRange,
      availableFrom: params.availableFrom,
      availableTo: params.availableTo,
      limit: params.pageSize + 1, // Fetch one extra to check if more exist
      offset: offset,
    );

    // Check if there are more results
    final hasMore = artists.length > params.pageSize;
    if (hasMore) {
      artists = artists.take(params.pageSize).toList();
    }

    // Apply client-side sorting if needed
    artists = _sortArtists(artists, params.sortBy, params.location);

    // Calculate total pages (this is an estimate)
    final totalCount = offset + artists.length + (hasMore ? 1 : 0);
    final totalPages = (totalCount / params.pageSize).ceil();

    return SearchArtistsResult(
      artists: artists,
      totalCount: totalCount,
      currentPage: params.page,
      totalPages: totalPages,
      hasMore: hasMore,
    );
  }

  List<ArtistProfile> _sortArtists(
    List<ArtistProfile> artists,
    SortBy sortBy,
    Location? userLocation,
  ) {
    switch (sortBy) {
      case SortBy.rating:
        artists.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortBy.distance:
        if (userLocation != null) {
          artists.sort((a, b) {
            final distA = a.location.distanceTo(userLocation);
            final distB = b.location.distanceTo(userLocation);
            return distA.compareTo(distB);
          });
        }
        break;
      case SortBy.priceAsc:
        artists.sort((a, b) => 
          a.priceRange.minPrice.compareTo(b.priceRange.minPrice));
        break;
      case SortBy.priceDesc:
        artists.sort((a, b) => 
          b.priceRange.maxPrice.compareTo(a.priceRange.maxPrice));
        break;
      case SortBy.newest:
        artists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortBy.relevance:
        // Already sorted by relevance from repository
        break;
    }
    return artists;
  }
}