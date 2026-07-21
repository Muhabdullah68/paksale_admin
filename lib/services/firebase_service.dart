import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // System Logs
  Future<void> _logAction(String action, String details) async {
    final user = _auth.currentUser;
    await _firestore.collection('system_logs').add({
      'adminEmail': user?.email ?? 'Unknown',
      'action': action,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getSystemLogs() {
    return _firestore
        .collection('system_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }

  // Users
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateUserStatus(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
    await _logAction('Update User Status', 'UID: $uid, Data: $data');
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
    await _logAction('Delete User', 'UID: $uid');
  }

  // Products
  Stream<List<ProductModel>> getPendingProducts() {
    return _firestore
        .collection('products')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<ProductModel>> getAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateProductStatus(String productId, ProductStatus status) async {
    await _firestore.collection('products').doc(productId).update({
      'status': status.toString().split('.').last,
    });
    await _logAction('Update Product Status', 'PID: $productId, Status: $status');
  }

  Future<void> markProductAsSold(String productId, String soldLocation, String? buyerNic) async {
    await _firestore.collection('products').doc(productId).update({
      'isSold': true,
      'soldLocation': soldLocation,
      'buyerNic': buyerNic,
    });
    await _logAction('Mark Product Sold', 'PID: $productId, Location: $soldLocation');
  }

  Future<void> updateProductPromotion(
      String productId, bool isFeatured, bool isBoosted) async {
    await _firestore.collection('products').doc(productId).update({
      'isFeatured': isFeatured,
      'isBoosted': isBoosted,
    });
    await _logAction('Update Product Promotion', 'PID: $productId, Featured: $isFeatured, Boosted: $isBoosted');
  }

  // Admin Management
  Future<void> createAdmin(String email, String password) async {
    // This requires Cloud Functions for production-grade admin management
    // For now, we store admin records in a collection
    await _firestore.collection('admins').add({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _logAction('Create Admin', 'Email: $email');
  }

  Stream<QuerySnapshot> getAdmins() {
    return _firestore.collection('admins').snapshots();
  }

  // Categories
  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection('categories').snapshots();
  }

  Future<void> addCategory(String name, String iconUrl) async {
    await _firestore.collection('categories').add({
      'name': name,
      'iconUrl': iconUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    await sendBroadcastNotification(
      'New Category Added',
      'We have added $name to our marketplace. Start exploring now!',
    );
    
    await _logAction('Add Category', 'Name: $name');
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
    await _logAction('Delete Category', 'ID: $id');
  }

  // Subcategories
  Stream<QuerySnapshot> getSubcategories(String categoryId) {
    return _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .orderBy('name')
        .snapshots();
  }

  Future<void> addSubcategory(String categoryId, String name) async {
    await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _logAction('Add Subcategory', 'CatID: $categoryId, Name: $name');
  }

  Future<void> deleteSubcategory(String categoryId, String subcategoryId) async {
    await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('subcategories')
        .doc(subcategoryId)
        .delete();
    await _logAction('Delete Subcategory', 'CatID: $categoryId, SubID: $subcategoryId');
  }

  Future<void> seedDefaultCategories() async {
    final categories = [
      {
        'name': 'Vehicles',
        'icon': '🚗',
        'order': 1,
        'subCategories': [
          {'name': 'All Vehicles', 'icon': '🚗'},
          {'name': 'Cars', 'icon': '🚙'},
          {'name': 'Motorcycles', 'icon': '🏍️'},
          {'name': 'Trucks', 'icon': '🚛'},
          {'name': 'Buses', 'icon': '🚌'},
          {'name': 'Spare Parts', 'icon': '🔧'}
        ]
      },
      {
        'name': 'Properties',
        'icon': '🏠',
        'order': 2,
        'subCategories': [
          {'name': 'All Properties', 'icon': '🏠'},
          {'name': 'Houses', 'icon': '🏡'},
          {'name': 'Apartments', 'icon': '🏢'},
          {'name': 'Commercial', 'icon': '🏪'},
          {'name': 'Plots', 'icon': '🌾'}
        ]
      },
      {
        'name': 'Electronics',
        'icon': '⚡',
        'order': 3,
        'subCategories': [
          {'name': 'All Electronics', 'icon': '⚡'},
          {'name': 'Mobile Phones', 'icon': '📱'},
          {'name': 'Tablets', 'icon': '📲'},
          {'name': 'Laptops', 'icon': '💻'},
          {'name': 'TVs', 'icon': '📺'},
          {'name': 'Consoles', 'icon': '🎮'}
        ]
      },
      {
        'name': 'Furniture & Decor',
        'icon': '🪑',
        'order': 4,
        'subCategories': [
          {'name': 'All Furniture', 'icon': '🪑'},
          {'name': 'Sofas', 'icon': '🛋️'},
          {'name': 'Tables', 'icon': '🪑'},
          {'name': 'Beds', 'icon': '🛏️'},
          {'name': 'Home Decor', 'icon': '🏠'}
        ]
      },
      {
        'name': 'WaterCrafts',
        'icon': '⛵',
        'order': 5,
        'subCategories': [
          {'name': 'All WaterCrafts', 'icon': '⛵'},
          {'name': 'Yachts', 'icon': '🛥️'},
          {'name': 'Jet Skis', 'icon': '🏄'},
          {'name': 'Boats', 'icon': '⛵'}
        ]
      },
      {
        'name': 'Jewellery',
        'icon': '💎',
        'order': 6,
        'subCategories': [
          {'name': 'All Jewellery', 'icon': '💎'},
          {'name': 'Rings', 'icon': '💍'},
          {'name': 'Necklaces', 'icon': '📿'},
          {'name': 'Watches', 'icon': '⌚'},
          {'name': 'Gold & Silver', 'icon': '🥇'}
        ]
      },
      {
        'name': 'Life Style',
        'icon': '🛍️',
        'order': 7,
        'subCategories': [
          {'name': 'All Lifestyle', 'icon': '🛍️'},
          {'name': 'Clothing', 'icon': '👕'},
          {'name': 'Health & Beauty', 'icon': '💄'},
          {'name': 'Sports', 'icon': '⚽'},
          {'name': 'Books', 'icon': '📚'}
        ]
      },
      {
        'name': 'Market',
        'icon': '🛒',
        'order': 8,
        'subCategories': [
          {'name': 'All Market', 'icon': '🛒'},
          {'name': 'Food', 'icon': '🍔'},
          {'name': 'Home & Garden', 'icon': '🌱'},
          {'name': 'Pets', 'icon': '🐕'},
          {'name': 'Tools', 'icon': '🔧'}
        ]
      },
      {
        'name': 'Outdoor & Leisure',
        'icon': '⛺',
        'order': 9,
        'subCategories': [
          {'name': 'All Outdoor', 'icon': '⛺'},
          {'name': 'Camping', 'icon': '🏕️'},
          {'name': 'Musical Instruments', 'icon': '🎸'},
          {'name': 'Fishing', 'icon': '🎣'},
          {'name': 'Cycling', 'icon': '🚴'}
        ]
      },
      {
        'name': 'Special Numbers',
        'icon': '🔢',
        'order': 10,
        'subCategories': [
          {'name': 'All Numbers', 'icon': '🔢'},
          {'name': 'VIP Mobile', 'icon': '📱'},
          {'name': 'Car Plates', 'icon': '🚗'}
        ]
      },
      {
        'name': 'Heavy Equipments',
        'icon': '🏗️',
        'order': 11,
        'subCategories': [
          {'name': 'All Equipments', 'icon': '🏗️'},
          {'name': 'Excavators', 'icon': '⛏️'},
          {'name': 'Cranes', 'icon': '🏗️'},
          {'name': 'Loaders', 'icon': '🚜'},
          {'name': 'Tractors', 'icon': '🚜'}
        ]
      },
      {
        'name': 'Jobs Center',
        'icon': '💼',
        'order': 12,
        'subCategories': [
          {'name': 'All Jobs', 'icon': '💼'},
          {'name': 'IT', 'icon': '💻'},
          {'name': 'Sales', 'icon': '💰'},
          {'name': 'Engineering', 'icon': '🔧'},
          {'name': 'Part Time', 'icon': '⏰'}
        ]
      },
      {
        'name': 'Super Ads',
        'icon': '⭐',
        'order': 13,
        'subCategories': [
          {'name': 'Featured', 'icon': '⭐'},
          {'name': 'Urgent Sales', 'icon': '⚡'}
        ]
      }
    ];

    for (var cat in categories) {
      final catQuery = await _firestore.collection('categories').where('name', isEqualTo: cat['name']).get();
      if (catQuery.docs.isEmpty) {
        await _firestore.collection('categories').add({
          'name': cat['name'],
          'icon': cat['icon'],
          'order': cat['order'],
          'subCategories': cat['subCategories'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await _logAction('Seed Categories', 'All categories seeded');
  }

  // CMS (Terms, Privacy, Help)
  Stream<DocumentSnapshot> getCMSContent(String docId) {
    return _firestore.collection('cms').doc(docId).snapshots();
  }

  Future<void> updateCMSContent(String docId, String content) async {
    await _firestore.collection('cms').doc(docId).set({
      'content': content,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    // Notify users about policy update
    String title = 'Policy Updated';
    if (docId == 'terms') title = 'Terms of Service Updated';
    if (docId == 'privacy') title = 'Privacy Policy Updated';
    
    await sendBroadcastNotification(
      title,
      'We have updated our $title. Please review the changes in the app.',
    );
    
    await _logAction('Update CMS', 'DocID: $docId');
  }

  // Banners
  Stream<QuerySnapshot> getBanners() {
    return _firestore.collection('banners').snapshots();
  }

  Future<void> addBanner(String imageUrl, String? link) async {
    await _firestore.collection('banners').add({
      'imageUrl': imageUrl,
      'link': link,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    await sendBroadcastNotification(
      'New Promotion!',
      'Check out our new featured banners for exciting offers.',
    );
    
    await _logAction('Add Banner', 'URL: $imageUrl');
  }

  Future<void> deleteBanner(String id) async {
    await _firestore.collection('banners').doc(id).delete();
    await _logAction('Delete Banner', 'ID: $id');
  }

  // Global Notifications (Broadcast)
  Future<void> sendBroadcastNotification(String title, String body) async {
    await _firestore.collection('broadcast_notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _logAction('Send Broadcast Notification', 'Title: $title');
  }

  // Notifications
  Future<void> sendNotification(String userId, String title, String body) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
    await _logAction('Send Personal Notification', 'UID: $userId, Title: $title');
  }

  // Get Single Item
  Future<DocumentSnapshot> getProduct(String id) {
    return _firestore.collection('products').doc(id).get();
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  // Reports (Moderation)
  Stream<QuerySnapshot> getReports() {
    return _firestore
        .collection('reports')
        // Removing orderBy temporarily as it might filter out documents missing the timestamp field
        // .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> updateReportStatus(String reportId, String status) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': status,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
    await _logAction('Update Report Status', 'ReportID: $reportId, Status: $status');
  }

  // General Settings
  Stream<DocumentSnapshot> getGeneralSettings() {
    return _firestore.collection('settings').doc('general').snapshots();
  }

  Future<void> updateGeneralSetting(String key, dynamic value) async {
    await _firestore.collection('settings').doc('general').set({
      key: value,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _logAction('Update General Setting', '$key: $value');
  }

  // Orders
  Stream<QuerySnapshot> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _logAction('Update Order Status', 'OrderID: $orderId, Status: $status');
  }

  // Generic helpers
  Stream<QuerySnapshot> getCollectionStream(String collectionName) {
    return _firestore.collection(collectionName).snapshots();
  }

  Future<void> addDocument(String collectionName, Map<String, dynamic> data) async {
    await _firestore.collection(collectionName).add(data);
    await _logAction('Add Document', 'Collection: $collectionName');
  }
}
