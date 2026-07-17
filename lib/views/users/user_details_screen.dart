import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../../constants/app_colors.dart';
import 'package:provider/provider.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'User Details',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile & Basic Info
                Expanded(
                  flex: 1,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.background,
                            backgroundImage: user.profileImage != null
                                ? CachedNetworkImageProvider(user.profileImage!)
                                : null,
                            child: user.profileImage == null
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            user.fullName,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            user.email ?? 'No email provided',
                            style: GoogleFonts.inter(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          _buildTierBadge(user.sellerTier),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 32),
                          _buildDetailRow('Phone', user.phoneNumber),
                          if (user.nicNumber != null)
                            _buildDetailRow('NIC Number', user.nicNumber!),
                          _buildDetailRow('Joined', DateFormat('MMM dd, yyyy').format(user.createdAt)),
                          _buildDetailRow('Status', user.isAdminApproved ? 'Active' : 'Suspended'),
                          _buildDetailRow('Business', user.isBusinessSeller ? 'Yes' : 'No'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                // Verification & Actions
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Verification Status Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Control',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  _buildVerificationStatusBox('ID Verification', user.idVerificationStatus),
                                  const SizedBox(width: 24),
                                  _buildVerificationStatusBox('Admin Approval', user.isAdminApproved ? 'approved' : 'pending'),
                                ],
                              ),
                              const SizedBox(height: 32),
                              const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  if (user.idVerificationStatus != 'approved')
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await firebaseService.updateUserStatus(
                                              user.uid, {'idVerificationStatus': 'approved'});
                                          if (context.mounted) Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.verified),
                                        label: const Text('Approve ID'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                      ),
                                    ),
                                  if (user.idVerificationStatus == 'approved')
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          await firebaseService.updateUserStatus(
                                              user.uid, {'idVerificationStatus': 'rejected'});
                                          if (context.mounted) Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.cancel),
                                        label: const Text('Reject ID'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                          side: const BorderSide(color: AppColors.error),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await firebaseService.updateUserStatus(
                                            user.uid, {'isAdminApproved': !user.isAdminApproved});
                                        if (context.mounted) Navigator.pop(context);
                                      },
                                      icon: Icon(user.isAdminApproved ? Icons.block : Icons.check_circle),
                                      label: Text(user.isAdminApproved ? 'Suspend User' : 'Unsuspend User'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: user.isAdminApproved ? AppColors.error : AppColors.success,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTierBadge(SellerTier tier) {
    Color color;
    switch (tier) {
      case SellerTier.premium: color = AppColors.accentGold; break;
      case SellerTier.verified: color = AppColors.success; break;
      case SellerTier.free: color = Colors.grey; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        tier.toString().split('.').last.toUpperCase(),
        style: GoogleFonts.inter(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildVerificationStatusBox(String title, String status) {
    Color color;
    switch (status) {
      case 'approved': color = AppColors.success; break;
      case 'pending': color = AppColors.warning; break;
      case 'rejected': color = AppColors.error; break;
      default: color = Colors.grey;
    }
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(
              status.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
