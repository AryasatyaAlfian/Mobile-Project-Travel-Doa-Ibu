/// Model data dari REST API backend. Nama field mengikuti JSON Laravel.
library;

class Paginated<T> {
  Paginated({required this.items, required this.currentPage, required this.lastPage, required this.total});

  factory Paginated.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromItem) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    return Paginated(
      items: (json['data'] as List).cast<Map<String, dynamic>>().map(fromItem).toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
    );
  }

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}

class PackageCategory {
  PackageCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.heroImage,
    this.packagesCount,
  });

  factory PackageCategory.fromJson(Map<String, dynamic> json) => PackageCategory(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String?,
        icon: json['icon'] as String?,
        heroImage: json['hero_image'] as String?,
        packagesCount: json['packages_count'] as int?,
      );

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? heroImage;
  final int? packagesCount;
}

class ItineraryDay {
  ItineraryDay({required this.dayNumber, required this.title, this.description, this.meals});

  factory ItineraryDay.fromJson(Map<String, dynamic> json) => ItineraryDay(
        dayNumber: json['day_number'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        meals: json['meals'] as String?,
      );

  final int dayNumber;
  final String title;
  final String? description;
  final String? meals;
}

class TravelPackage {
  TravelPackage({
    required this.id,
    required this.name,
    required this.slug,
    required this.formattedPrice,
    this.excerpt,
    this.duration,
    this.departureDate,
    this.startingPrice,
    this.quota,
    this.isFeatured = false,
    this.image,
    this.category,
    this.description,
    this.images = const [],
    this.itineraries = const [],
    this.inclusions = const [],
    this.exclusions = const [],
  });

  factory TravelPackage.fromJson(Map<String, dynamic> json) => TravelPackage(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        formattedPrice: json['formatted_price'] as String? ?? 'Hubungi Kami',
        excerpt: json['excerpt'] as String?,
        duration: json['duration'] as String?,
        departureDate: json['departure_date'] != null ? DateTime.tryParse(json['departure_date'] as String) : null,
        startingPrice: (json['starting_price'] as num?)?.toDouble(),
        quota: json['quota'] as int?,
        isFeatured: json['is_featured'] as bool? ?? false,
        image: json['image'] as String?,
        category: json['category'] is Map<String, dynamic>
            ? PackageCategory.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        description: json['description'] as String?,
        images: (json['images'] as List?)?.map((e) => (e as Map)['url'] as String?).whereType<String>().toList() ?? const [],
        itineraries: (json['itineraries'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(ItineraryDay.fromJson)
                .toList() ??
            const [],
        inclusions: (json['inclusions'] as List?)?.map((e) => '$e').toList() ?? const [],
        exclusions: (json['exclusions'] as List?)?.map((e) => '$e').toList() ?? const [],
      );

  final int id;
  final String name;
  final String slug;
  final String formattedPrice;
  final String? excerpt;
  final String? duration;
  final DateTime? departureDate;
  final double? startingPrice;
  final int? quota;
  final bool isFeatured;
  final String? image;
  final PackageCategory? category;

  // Hanya terisi dari endpoint detail.
  final String? description;
  final List<String> images;
  final List<ItineraryDay> itineraries;
  final List<String> inclusions;
  final List<String> exclusions;
}

class Testimonial {
  Testimonial({required this.id, required this.customerName, required this.content, this.rating, this.tripType, this.photo});

  factory Testimonial.fromJson(Map<String, dynamic> json) => Testimonial(
        id: json['id'] as int,
        customerName: json['customer_name'] as String,
        content: json['content'] as String,
        rating: json['rating'] as int?,
        tripType: json['trip_type'] as String?,
        photo: json['customer_photo'] as String?,
      );

  final int id;
  final String customerName;
  final String content;
  final int? rating;
  final String? tripType;
  final String? photo;
}

class BlogPost {
  BlogPost({required this.id, required this.title, required this.slug, this.excerpt, this.content, this.image, this.publishedAt});

  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
        id: json['id'] as int,
        title: json['title'] as String,
        slug: json['slug'] as String,
        excerpt: json['excerpt'] as String?,
        content: json['content'] as String?,
        image: json['featured_image'] as String?,
        publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at'] as String) : null,
      );

  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String? image;
  final DateTime? publishedAt;
}

class AppUser {
  AppUser({required this.id, required this.name, required this.email, required this.isAdmin});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        isAdmin: json['is_admin'] as bool? ?? false,
      );

  final int id;
  final String name;
  final String email;
  final bool isAdmin;
}

/// Data form pemesanan. Field & aturan sama dengan form /pemesanan di web.
class BookingRequest {
  BookingRequest({
    required this.packageCategoryId,
    required this.customerName,
    required this.customerWhatsapp,
    required this.customerEmail,
    required this.customerCity,
    required this.participants,
    this.packageId,
    this.preferredDate,
    this.specialRequests,
    this.contactPreference = 'whatsapp',
  });

  final int packageCategoryId;
  final int? packageId;
  final String customerName;
  final String customerWhatsapp; // format 08xxxxxxxxxx
  final String customerEmail;
  final String customerCity;
  final int participants;
  final DateTime? preferredDate;
  final String? specialRequests;
  final String contactPreference; // whatsapp | email | phone

  Map<String, dynamic> toJson() => {
        'package_category_id': packageCategoryId,
        if (packageId != null) 'package_id': packageId,
        'customer_name': customerName,
        'customer_whatsapp': customerWhatsapp,
        'customer_email': customerEmail,
        'customer_city': customerCity,
        'participants': participants,
        if (preferredDate != null) 'preferred_date': preferredDate!.toIso8601String().substring(0, 10),
        if (specialRequests != null) 'special_requests': specialRequests,
        'contact_preference': contactPreference,
        'terms_accepted': true,
      };
}
