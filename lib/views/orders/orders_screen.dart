import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../constants/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _statusFilter = 'all';

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'confirmed': return AppColors.accentGold;
      case 'shipped': return Colors.blue;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COD Orders',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary,
                        )),
                    const SizedBox(height: 4),
                    Text('Manage cash-on-delivery orders from the marketplace',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Orders')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                        DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firebaseService.getAllOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var docs = snapshot.data?.docs ?? [];
                  if (_statusFilter != 'all') {
                    docs = docs.where((d) => d['status'] == _statusFilter).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('No orders found', style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final status = data['status'] ?? 'pending';
                      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  image: data['productImage'] != null && (data['productImage'] as String).isNotEmpty
                                      ? DecorationImage(image: NetworkImage(data['productImage']), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: data['productImage'] == null || (data['productImage'] as String).isEmpty
                                    ? const Icon(Icons.image, color: AppColors.textSecondary)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['productTitle'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text('QAR ${(data['price'] ?? 0).toStringAsFixed(0)}', style: GoogleFonts.inter(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text('Buyer: ${data['buyerName'] ?? 'N/A'} / Seller: ${data['sellerName'] ?? 'N/A'}',
                                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                    ]),
                                    if (data['deliveryLocation'] != null && (data['deliveryLocation'] as String).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Row(children: [
                                          Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text('${data['deliveryLocation']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                        ]),
                                      ),
                                    if (data['buyerAddress'] != null && (data['buyerAddress'] as String).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Row(children: [
                                          Icon(Icons.home, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text('Address: ${data['buyerAddress']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                        ]),
                                      ),
                                    if (createdAt != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(DateFormat('MMM dd, yyyy HH:mm').format(createdAt),
                                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _statusColor(status).withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  (status as String).toUpperCase(),
                                  style: GoogleFonts.inter(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 16),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                                onSelected: (value) async {
                                  await firebaseService.updateOrderStatus(doc.id, value);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Order ${value}ed'),
                                      backgroundColor: AppColors.success,
                                    ));
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (status == 'pending')
                                    const PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                                  if (status == 'confirmed')
                                    const PopupMenuItem(value: 'delivered', child: Text('Mark Delivered')),
                                  if (status == 'pending' || status == 'confirmed')
                                    const PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
