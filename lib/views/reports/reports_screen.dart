import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firebase_service.dart';
import '../../models/product_model.dart';
import '../../constants/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moderation Center',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review user reports and maintain marketplace integrity',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Pending Investigation', Icons.gavel_rounded),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firebaseService.getReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('All Clear!', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('No active reports require attention.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  final docs = List.from(snapshot.data!.docs);
                  docs.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    final timeA = (dataA['timestamp'] ?? dataA['createdAt']) as Timestamp?;
                    final timeB = (dataB['timestamp'] ?? dataB['createdAt']) as Timestamp?;
                    if (timeA == null) return 1;
                    if (timeB == null) return -1;
                    return timeB.compareTo(timeA);
                  });
                  
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final report = docs[index];
                      final data = report.data() as Map<String, dynamic>;
                      final status = data['status'] ?? 'pending';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (status == 'resolved' ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              status == 'resolved' ? Icons.verified_user_rounded : Icons.report_gmailerrorred_rounded,
                              color: status == 'resolved' ? AppColors.success : AppColors.warning,
                              size: 28,
                            ),
                          ),
                          title: FutureBuilder<DocumentSnapshot>(
                            future: (data['targetType']?.toString().toLowerCase() == 'product')
                                ? firebaseService.getProduct(data['targetId'] ?? '')
                                : firebaseService.getUser(data['targetId'] ?? ''),
                            builder: (context, targetSnapshot) {
                              String targetName = 'Unknown Entity';
                              String targetType = data['targetType']?.toString().toUpperCase() ?? 'REPORT';
                              
                              if (targetSnapshot.connectionState == ConnectionState.waiting) {
                                return Text('Loading details...', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey));
                              }

                              if (targetSnapshot.hasData && targetSnapshot.data!.exists) {
                                final targetData = targetSnapshot.data!.data() as Map<String, dynamic>;
                                targetName = (data['targetType']?.toString().toLowerCase() == 'product')
                                    ? (targetData['title'] ?? 'Untitled Product')
                                    : (targetData['fullName'] ?? 'Unnamed User');
                              } else if (targetSnapshot.hasError) {
                                targetName = 'Data Fetch Error';
                              } else if (targetSnapshot.connectionState == ConnectionState.done && !targetSnapshot.data!.exists) {
                                targetName = 'Entity Deleted/Not Found';
                              }

                              return Row(
                                children: [
                                  Text(
                                    '$targetType: ',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: AppColors.primary.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      targetName,
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  'REASON: ${data['reason'] ?? 'No reason provided'}',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Reported by: ${data['reporterName'] ?? data['reporterId'] ?? 'Anonymous'}',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatTimestamp(data['timestamp'] ?? data['createdAt']),
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _viewReportTarget(context, firebaseService, data['targetType'] ?? 'Unknown', data['targetId'] ?? ''),
                                icon: const Icon(Icons.visibility_rounded, size: 18),
                                label: const Text('Examine Content'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                          trailing: status == 'pending' 
                            ? ElevatedButton(
                                onPressed: () => _showResolveDialog(context, firebaseService, report.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Resolve'),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'RESOLVED',
                                  style: GoogleFonts.inter(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return 'Invalid time';
    }
    return '${date.day}/${date.month}/${date.year}';
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

  void _viewReportTarget(BuildContext context, FirebaseService service, String type, String id) async {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target ID is missing')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      DocumentSnapshot doc;
      if (type.toLowerCase() == 'product') {
        doc = await service.getProduct(id);
      } else {
        doc = await service.getUser(id);
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        if (!doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target content no longer exists')));
          return;
        }

        final data = doc.data() as Map<String, dynamic>;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Reported ${type.capitalize()} Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type.toLowerCase() == 'product') ...[
                    if (data['images'] != null && (data['images'] as List).isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: data['images'][0],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text('Title: ${data['title'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Price: QAR ${data['price'] ?? '0'}'),
                    Text('Description: ${data['description'] ?? 'No description'}'),
                  ] else ...[
                    Text('Name: ${data['fullName'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Email: ${data['email'] ?? 'N/A'}'),
                    Text('Phone: ${data['phoneNumber'] ?? 'N/A'}'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              if (type.toLowerCase() == 'product')
                ElevatedButton(
                  onPressed: () async {
                    await service.updateProductStatus(id, ProductStatus.rejected);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product blocked')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Block Product', style: TextStyle(color: Colors.white)),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    await service.updateUserStatus(id, {'isAdminApproved': false});
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User suspended')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Suspend User', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading target: $e')));
      }
    }
  }

  void _showResolveDialog(BuildContext context, FirebaseService service, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Report'),
        content: const Text('Mark this report as resolved? Make sure you have taken appropriate action (e.g., warned or banned the user).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await service.updateReportStatus(id, 'resolved');
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report marked as resolved')),
                );
              }
            },
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
