import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../constants/app_colors.dart';

class DashboardHome extends StatelessWidget {
  final Function(int) onCardTap;
  final Function({ProductStatus? status, bool? featured}) onNavigateToProducts;
  final Function({SellerTier? tier}) onNavigateToUsers;

  const DashboardHome({
    super.key,
    required this.onCardTap,
    required this.onNavigateToProducts,
    required this.onNavigateToUsers,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Overview',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor platform activity and manage key metrics in real-time',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Key Performance Indicators', Icons.analytics_rounded),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryCard(
                  'Pending Ads',
                  firebaseService.getPendingProducts(),
                  (List<ProductModel> items) => items.length.toString(),
                  Icons.pending_actions,
                  AppColors.warning,
                  onTap: () => onNavigateToProducts(status: ProductStatus.pending),
                ),
                const SizedBox(width: 20),
                _buildSummaryCard(
                  'Total Users',
                  firebaseService.getUsers(),
                  (List<UserModel> items) => items.length.toString(),
                  Icons.people,
                  AppColors.primary,
                  onTap: () => onNavigateToUsers(),
                ),
                const SizedBox(width: 20),
                _buildSummaryCard(
                  'Verified Sellers',
                  firebaseService.getUsers(),
                  (List<UserModel> items) => 
                    items.where((u) => u.sellerTier != SellerTier.free).length.toString(),
                  Icons.verified_user,
                  AppColors.success,
                  onTap: () => onNavigateToUsers(tier: SellerTier.verified),
                ),
                const SizedBox(width: 20),
                _buildSummaryCard(
                  'Premium Ads',
                  firebaseService.getAllProducts(),
                  (List<ProductModel> items) => 
                    items.where((p) => p.isFeatured).length.toString(),
                  Icons.star,
                  AppColors.accentGold,
                  onTap: () => onNavigateToProducts(featured: true),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Content & Logs', Icons.data_usage_rounded),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStreamSummaryCard(
                  'Total Categories',
                  firebaseService.getCategories(),
                  Icons.category,
                  AppColors.primary,
                  onTap: () => onCardTap(6),
                ),
                const SizedBox(width: 20),
                _buildStreamSummaryCard(
                  'Active Banners',
                  firebaseService.getBanners(),
                  Icons.image,
                  AppColors.accentGold,
                  onTap: () => onCardTap(6),
                ),
                const SizedBox(width: 20),
                _buildStreamSummaryCard(
                  'Active Reports',
                  firebaseService.getReports(),
                  Icons.report_problem,
                  AppColors.error,
                  onTap: () => onCardTap(4),
                ),
                const SizedBox(width: 20),
                _buildStreamSummaryCard(
                  'COD Orders',
                  firebaseService.getAllOrders(),
                  Icons.receipt_long,
                  AppColors.success,
                  onTap: () => onCardTap(2),
                ),
              ],
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Recent System Logs', Icons.history_edu_rounded),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: firebaseService.getSystemLogs(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final logs = snapshot.data!.docs.take(10).toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 24, endIndent: 24),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.background,
                          child: Icon(Icons.history, color: AppColors.primary, size: 20),
                        ),
                        title: Text(log['action'], style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        subtitle: Text(log['details'], style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                        onTap: () => _showLogDetail(context, log),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _showLogDetail(BuildContext context, QueryDocumentSnapshot log) {
    final data = log.data() as Map<String, dynamic>;
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Entry Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Action', data['action']),
            _buildDetailRow('Admin', data['adminEmail']),
            _buildDetailRow('Details', data['details']),
            _buildDetailRow('Time', timestamp != null ? timestamp.toString() : 'Unknown'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamSummaryCard(
    String title,
    Stream<QuerySnapshot> stream,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
          return Card(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      count,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard<T>(
    String title,
    Stream<List<T>> stream,
    String Function(List<T>) countBuilder,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: StreamBuilder<List<T>>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.hasData ? countBuilder(snapshot.data!) : '...';
          return Card(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      count,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
