import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductStatus { pending, approved, rejected }

class ProductModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final String? subCategory;
  final ProductStatus status;
  final bool isFeatured;
  final bool isBoosted;
  final bool isSold;
  final bool isVerifiedSeller;
  final List<String> searchKeywords;
  final String location;
  final String city;
  final String village;
  final String? soldLocation; // Location where the product was sold
  final String? buyerNic; // NIC of the buyer for transparency if > 20k
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.images, // Note: Limit to 2 photos for cost control
    required this.category,
    this.subCategory,
    required this.status,
    required this.isFeatured,
    required this.isBoosted,
    required this.isSold,
    required this.isVerifiedSeller,
    required this.searchKeywords,
    this.location = 'Qatar',
    required this.city,
    required this.village,
    this.soldLocation,
    this.buyerNic,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      sellerId: map['sellerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      subCategory: map['subCategory'],
      status: ProductStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'pending'),
        orElse: () => ProductStatus.pending,
      ),
      isFeatured: map['isFeatured'] ?? false,
      isBoosted: map['isBoosted'] ?? false,
      isSold: map['isSold'] ?? false,
      isVerifiedSeller: map['isVerifiedSeller'] ?? false,
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []),
      location: map['location'] ?? 'Qatar',
      city: map['city'] ?? '',
      village: map['village'] ?? '',
      soldLocation: map['soldLocation'],
      buyerNic: map['buyerNic'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'images': images.take(2).toList(), // Enforce 2 photos limit on save
      'category': category,
      'subCategory': subCategory,
      'status': status.toString().split('.').last,
      'isFeatured': isFeatured,
      'isBoosted': isBoosted,
      'isSold': isSold,
      'isVerifiedSeller': isVerifiedSeller,
      'searchKeywords': searchKeywords,
      'location': location,
      'city': city,
      'village': village,
      'soldLocation': soldLocation,
      'buyerNic': buyerNic,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
