import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import '../../constants/app_colors.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  final ProductStatus? initialStatus;
  final bool? filterFeatured;
  
  const ProductsScreen({super.key, this.initialStatus, this.filterFeatured});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  ProductStatus? _statusFilter;
  bool? _featuredFilter;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialStatus;
    _featuredFilter = widget.filterFeatured;
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
                    Text(
                      'Inventory Moderation',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Approve, feature, or manage marketplace listings',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ProductStatus?>(
                          value: _statusFilter,
                          hint: Text('Status', style: GoogleFonts.inter(fontSize: 13)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Status')),
                            ...ProductStatus.values.map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.toString().split('.').last.toUpperCase()),
                                )),
                          ],
                          onChanged: (val) => setState(() => _statusFilter = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilterChip(
                      label: Text('Featured', style: GoogleFonts.inter(fontSize: 13)),
                      selected: _featuredFilter ?? false,
                      onSelected: (val) => setState(() => _featuredFilter = val ? true : null),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.accentGold.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.accentGold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Marketplace Listings', Icons.inventory_2_rounded),
            const SizedBox(height: 16),
            Expanded(
              child: RepaintBoundary(
                child: Container(
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
                  child: StreamBuilder<List<ProductModel>>(
                    stream: firebaseService.getAllProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      var products = snapshot.data ?? [];
                      
                      // Apply local filters
                      if (_statusFilter != null) {
                        products = products.where((p) => p.status == _statusFilter).toList();
                      }
                      if (_featuredFilter == true) {
                        products = products.where((p) => p.isFeatured).toList();
                      }
                      
                      return DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 24,
                        minWidth: 900,
                        headingRowColor: WidgetStateProperty.all(AppColors.background.withValues(alpha: 0.5)),
                        headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary),
                        columns: [
                          DataColumn2(label: Text('Image'), size: ColumnSize.S),
                          DataColumn2(label: Text('Title'), size: ColumnSize.L),
                          DataColumn(label: Text('Price (QAR)')),
                          DataColumn(label: Text('Location')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: products.map((product) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected != null && selected) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(product: product),
                                  ),
                                );
                              }
                            },
                            cells: [
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product.images.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: product.images[0],
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            width: 45,
                                            height: 45,
                                            color: Colors.grey[100],
                                            child: const Center(
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            width: 45,
                                            height: 45,
                                            color: Colors.grey[100],
                                            child: const Icon(Icons.error, size: 20),
                                          ),
                                        )
                                      : Container(
                                          width: 45,
                                          height: 45,
                                          color: Colors.grey[100],
                                          child: const Icon(Icons.image_not_supported, size: 20),
                                        ),
                                ),
                              ),
                            ),
                            DataCell(Text(product.title, style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
                            DataCell(Text(product.price.toStringAsFixed(0), style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                            DataCell(Text('${product.city}, ${product.village}', style: GoogleFonts.inter(fontSize: 12))),
                            DataCell(_buildStatusChip(product.status)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, color: AppColors.primary),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailsScreen(product: product),
                                      ),
                                    );
                                  },
                                  tooltip: 'View Details',
                                ),
                                if (product.status == ProductStatus.pending)
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                                    onPressed: () async {
                                      await firebaseService.updateProductStatus(
                                          product.id, ProductStatus.approved);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Product approved')),
                                        );
                                      }
                                    },
                                    tooltip: 'Approve',
                                  ),
                                if (product.status == ProductStatus.pending)
                                  IconButton(
                                    icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                                    onPressed: () async {
                                      await firebaseService.updateProductStatus(
                                          product.id, ProductStatus.rejected);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Product rejected')),
                                        );
                                      }
                                    },
                                    tooltip: 'Reject',
                                  ),
                                IconButton(
                                  icon: Icon(
                                    product.isFeatured ? Icons.stars_rounded : Icons.stars_rounded,
                                    color: product.isFeatured ? AppColors.accentGold : Colors.grey[300],
                                  ),
                                  onPressed: () async {
                                    await firebaseService.updateProductPromotion(
                                        product.id, !product.isFeatured, product.isBoosted);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(product.isFeatured ? 'Promotion removed' : 'Product featured')),
                                      );
                                    }
                                  },
                                  tooltip: 'Toggle Featured',
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
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
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.toString().split('.').last.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}
