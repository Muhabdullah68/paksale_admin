import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../../constants/app_colors.dart';
import 'user_details_screen.dart';

class UsersScreen extends StatefulWidget {
  final SellerTier? initialTier;
  const UsersScreen({super.key, this.initialTier});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  SellerTier? _tierFilter;

  @override
  void initState() {
    super.initState();
    _tierFilter = widget.initialTier;
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
                      'Member Management',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage platform access, verify identity, and moderate user accounts',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddUserDialog(context, firebaseService),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('ADD NEW MEMBER'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SellerTier?>(
                          value: _tierFilter,
                          dropdownColor: Colors.white,
                          hint: Text('FILTER BY TIER', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('ALL TIERS')),
                            ...SellerTier.values.map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.toString().split('.').last.toUpperCase()),
                                )),
                          ],
                          onChanged: (val) => setState(() => _tierFilter = val),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Registered Members List', Icons.group_rounded),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: StreamBuilder<List<UserModel>>(
                  stream: firebaseService.getUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    
                    var users = snapshot.data ?? [];
                    
                    if (_tierFilter != null) {
                      users = users.where((u) => u.sellerTier == _tierFilter).toList();
                    }
                    
                    return DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 24,
                      minWidth: 1000,
                      headingRowHeight: 60,
                      dataRowHeight: 70,
                      headingRowColor: WidgetStateProperty.all(AppColors.background.withValues(alpha: 0.5)),
                      headingTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                      columns: const [
                        DataColumn2(label: Text('MEMBER NAME'), size: ColumnSize.L),
                        DataColumn2(label: Text('EMAIL ADDRESS'), size: ColumnSize.L),
                        DataColumn(label: Text('TIER STATUS')),
                        DataColumn(label: Text('VERIFICATION')),
                        DataColumn(label: Text('BUSINESS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: users.map((user) {
                        return DataRow(
                          onSelectChanged: (selected) {
                            if (selected != null && selected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetailsScreen(user: user),
                                ),
                              );
                            }
                          },
                          cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: Text(
                                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(user.fullName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          DataCell(Text(user.email ?? 'N/A', style: GoogleFonts.inter(color: AppColors.textSecondary))),
                          DataCell(_buildTierChip(user.sellerTier)),
                          DataCell(_buildVerificationChip(user.idVerificationStatus)),
                          DataCell(Icon(
                            user.isBusinessSeller ? Icons.verified_rounded : Icons.person_outline_rounded,
                            color: user.isBusinessSeller ? AppColors.success : Colors.grey[300],
                            size: 20,
                          )),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserDetailsScreen(user: user),
                                    ),
                                  );
                                },
                                tooltip: 'User Details',
                              ),
                              IconButton(
                                icon: Icon(
                                  user.isAdminApproved ? Icons.person_off_rounded : Icons.check_circle_rounded,
                                  color: user.isAdminApproved ? AppColors.error : AppColors.success,
                                ),
                                onPressed: () {
                                  final action = user.isAdminApproved ? 'Suspend' : 'Activate';
                                  _showActionDialog(
                                    context, 
                                    '$action User', 
                                    'Are you sure you want to $action ${user.fullName}? This will ${action == 'Suspend' ? 'revoke' : 'restore'} their platform access.', 
                                    () async {
                                      await firebaseService.updateUserStatus(user.uid, {'isAdminApproved': !user.isAdminApproved});
                                    }
                                  );
                                },
                                tooltip: user.isAdminApproved ? 'Suspend User' : 'Activate User',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                                onPressed: () {
                                  _showDeleteUserDialog(context, firebaseService, user);
                                },
                                tooltip: 'Remove Member',
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

  void _showActionDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, FirebaseService service, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to permanently remove ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await service.deleteUser(user.uid);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, FirebaseService service) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final nicController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Member'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'Required if amount > 20,000',
                ),
                validator: (v) {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 20000 && (v == null || v.isEmpty)) {
                    return 'Email required for amounts > 20,000';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: nicController,
                decoration: const InputDecoration(
                  labelText: 'NIC Number (Optional)',
                  hintText: 'Required if amount > 20,000',
                ),
                validator: (v) {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 20000 && (v == null || v.isEmpty)) {
                    return 'NIC required for amounts > 20,000';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Initial Transaction Amount (Rs)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => formKey.currentState?.validate(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final newUser = UserModel(
                uid: DateTime.now().millisecondsSinceEpoch.toString(),
                email: emailController.text.isEmpty ? null : emailController.text,
                fullName: nameController.text,
                phoneNumber: phoneController.text,
                nicNumber: nicController.text.isEmpty ? null : nicController.text,
                sellerTier: SellerTier.free,
                isBusinessSeller: false,
                isAdminApproved: true,
                idVerificationStatus: 'pending',
                createdAt: DateTime.now(),
              );
              await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set(newUser.toMap());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTierChip(SellerTier tier) {
    Color color;
    switch (tier) {
      case SellerTier.premium:
        color = AppColors.accentGold;
        break;
      case SellerTier.verified:
        color = AppColors.success;
        break;
      case SellerTier.free:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        tier.toString().split('.').last.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildVerificationChip(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}
