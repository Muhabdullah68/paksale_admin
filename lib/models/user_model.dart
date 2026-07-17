import 'package:cloud_firestore/cloud_firestore.dart';

enum SellerTier { free, verified, premium }

class UserModel {
  final String uid;
  final String? email;
  final String fullName;
  final String phoneNumber;
  final String? profileImage;
  final String? nicNumber; // Added for > 20k requirement
  final SellerTier sellerTier;
  final bool isBusinessSeller;
  final bool isAdminApproved;
  final String idVerificationStatus; // pending, approved, rejected
  final DateTime createdAt;

  UserModel({
    required this.uid,
    this.email,
    required this.fullName,
    required this.phoneNumber,
    this.profileImage,
    this.nicNumber,
    required this.sellerTier,
    required this.isBusinessSeller,
    required this.isAdminApproved,
    required this.idVerificationStatus,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'],
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'],
      nicNumber: map['nicNumber'],
      sellerTier: SellerTier.values.firstWhere(
        (e) => e.toString().split('.').last == (map['sellerTier'] ?? 'free'),
        orElse: () => SellerTier.free,
      ),
      isBusinessSeller: map['isBusinessSeller'] ?? false,
      isAdminApproved: map['isAdminApproved'] ?? false,
      idVerificationStatus: map['idVerificationStatus'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'nicNumber': nicNumber,
      'sellerTier': sellerTier.toString().split('.').last,
      'isBusinessSeller': isBusinessSeller,
      'isAdminApproved': isAdminApproved,
      'idVerificationStatus': idVerificationStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
