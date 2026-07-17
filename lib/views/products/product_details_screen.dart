import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import '../../constants/app_colors.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Product Details',
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
                // Image Gallery
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: product.images.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: product.images[0],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, size: 100),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (product.images.length > 1)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: product.images.length - 1,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: product.images[index + 1],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Product Info
                Expanded(
                  flex: 3,
                  child: Card(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusChip(product.status),
                              Text(
                                DateFormat('MMM dd, yyyy').format(product.createdAt),
                                style: GoogleFonts.inter(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            product.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'QAR ${product.price.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildInfoSection('Description', product.description),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: _buildInfoSection('Category', product.category)),
                              Expanded(child: _buildInfoSection('Location', '${product.city}, ${product.village}')),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildInfoSection('Seller ID', product.sellerId),
                          const SizedBox(height: 24),
                          if (product.isSold) ...[
                            const Divider(),
                            const SizedBox(height: 24),
                            Text(
                              'Sales Information (Transparency)',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoSection('Sold Location', product.soldLocation ?? 'Not specified'),
                            if (product.buyerNic != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: _buildInfoSection('Buyer NIC', product.buyerNic!),
                              ),
                          ] else if (product.status == ProductStatus.approved) ...[
                            const Divider(),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showMarkAsSoldDialog(context, firebaseService),
                                icon: const Icon(Icons.sell_rounded),
                                label: const Text('MARK AS SOLD'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentGold,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                          const Divider(),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: product.status == ProductStatus.approved
                                      ? null
                                      : () async {
                                          await firebaseService.updateProductStatus(
                                              product.id, ProductStatus.approved);
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Listing Approved & Published'),
                                                backgroundColor: AppColors.success,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.verified_user_rounded),
                                  label: const Text('APPROVE LISTING'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: product.status == ProductStatus.rejected
                                      ? null
                                      : () async {
                                          await firebaseService.updateProductStatus(
                                              product.id, ProductStatus.rejected);
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Listing Disapproved & Hidden'),
                                                backgroundColor: AppColors.error,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.block_rounded),
                                  label: const Text('DISAPPROVE LISTING'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(color: AppColors.error, width: 2),
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkAsSoldDialog(BuildContext context, FirebaseService firebaseService) {
    final locationController = TextEditingController();
    final nicController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final bool needsNic = product.price > 20000;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Product as Sold', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please provide the following details for transparency.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Sold Location',
                  hintText: 'e.g. Doha City Center',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Location is required' : null,
              ),
              if (needsNic) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: nicController,
                  decoration: const InputDecoration(
                    labelText: 'Buyer NIC Number',
                    hintText: 'Required for transactions > 20,000 Rs',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'NIC is required for high-value sales' : null,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await firebaseService.markProductAsSold(
                  product.id,
                  locationController.text,
                  needsNic ? nicController.text : null,
                );
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to products screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product marked as sold successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('CONFIRM SALE'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ProductStatus status) {
    Color color;
    switch (status) {
      case ProductStatus.approved:
        color = AppColors.success;
        break;
      case ProductStatus.pending:
        color = AppColors.warning;
        break;
      case ProductStatus.rejected:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
