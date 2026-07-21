import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firebase_service.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  void _showAddAdminDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _adminEmailController,
              decoration: const InputDecoration(labelText: 'Admin Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _adminPasswordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final firebaseService = Provider.of<FirebaseService>(context, listen: false);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              try {
                await firebaseService.createAdmin(
                  _adminEmailController.text.trim(),
                  _adminPasswordController.text.trim(),
                );
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Admin added successfully')),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error adding admin: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

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
            // --- Premium Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Configuration',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your platform settings and administrative controls',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                _buildLogoutButton(context),
              ],
            ),
            const SizedBox(height: 40),

            // --- Admin Management Section ---
            _buildSectionHeader('Administrative Control', Icons.security),
            const SizedBox(height: 16),
            _buildAdminManagementCard(context, firebaseService),

            const SizedBox(height: 40),

            // --- General System Settings ---
            _buildSectionHeader('General System Settings', Icons.settings_applications_rounded),
            const SizedBox(height: 16),
            _buildGeneralSettingsCard(context, firebaseService),

            const SizedBox(height: 40),

            // --- Content Management Grid ---
            _buildSectionHeader('Marketplace Experience', Icons.auto_awesome),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFancyActionCard(
                  context,
                  'Promotional Banners',
                  'High-impact visual ads for the home screen',
                  Icons.ad_units_rounded,
                  AppColors.primary,
                  () => _showBannerManagement(context),
                ),
                _buildFancyActionCard(
                  context,
                  'Global Categories',
                  'Organize marketplace hierarchy and icons',
                  Icons.grid_view_rounded,
                  AppColors.accentGold,
                  () => _showCategoryManagement(context),
                ),
                _buildFancyActionCard(
                  context,
                  'Push Notifications',
                  'Direct engagement broadcast to all users',
                  Icons.send_time_extension_rounded,
                  AppColors.success,
                  () => _showPushNotificationDialog(context),
                ),
                _buildFancyActionCard(
                  context,
                  'Safe Meeting Locations',
                  'Manage public meeting places for safe transactions',
                  Icons.location_city_rounded,
                  Colors.teal,
                  () => _showSafeMeetingLocations(context),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- CMS Section ---
            _buildSectionHeader('Legal & Compliance', Icons.gavel_rounded),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFancyActionCard(
                    context,
                    'Terms of Service',
                    'Platform usage rules and user agreements',
                    Icons.article_rounded,
                    Colors.blueGrey,
                    () => _showCMSEditor(context, 'terms', 'Terms of Service'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildFancyActionCard(
                    context,
                    'Privacy Policy',
                    'Data protection and privacy standards',
                    Icons.privacy_tip_rounded,
                    Colors.indigo,
                    () => _showCMSEditor(context, 'privacy', 'Privacy Policy'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildFancyActionCard(
                    context,
                    'Support & FAQ',
                    'Help center and customer service portal',
                    Icons.contact_support_rounded,
                    Colors.teal,
                    () => _showCMSEditor(context, 'help', 'Help & Support'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- Maintenance Section ---
            _buildSectionHeader('System Maintenance', Icons.settings_suggest_rounded),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFancyActionCard(
                    context,
                    'Audit Logs',
                    'Track every administrative action and change',
                    Icons.history_edu_rounded,
                    AppColors.textSecondary,
                    () => _showSystemLogs(context),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildFancyActionCard(
                    context,
                    'Cloud Backups',
                    'Automated data snapshot and recovery',
                    Icons.cloud_done_rounded,
                    AppColors.info,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Daily backups are automated in Firebase')),
                      );
                    },
                  ),
                ),
                const Expanded(child: SizedBox()), // Placeholder for balance
              ],
            ),
            const SizedBox(height: 60),
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

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.power_settings_new_rounded, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('End Session?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of the admin panel?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminManagementCard(BuildContext context, FirebaseService service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.admin_panel_settings, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team Access Control',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          'Manage roles and platform permissions',
                          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddAdminDialog,
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('New Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          StreamBuilder<QuerySnapshot>(
            stream: service.getAdmins(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 24, endIndent: 24),
                itemBuilder: (context, index) {
                  final admin = snapshot.data!.docs[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey[50],
                      child: Text(
                        admin['email'][0].toUpperCase(),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(admin['email'], style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    subtitle: const Text('Full Administrative Access'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: AppColors.error.withValues(alpha: 0.7)),
                      onPressed: () => _confirmDeleteAdmin(context, admin),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsCard(BuildContext context, FirebaseService service) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: service.getGeneralSettings(),
        builder: (context, snapshot) {
          final data = snapshot.hasData && snapshot.data!.exists
              ? snapshot.data!.data() as Map<String, dynamic>
              : {};

          return Column(
            children: [
              _buildSettingToggle(
                'Dark Mode',
                'Switch between light and dark themes',
                isDarkMode,
                (val) => themeProvider.toggleTheme(),
              ),
              const Divider(height: 32),
              _buildSettingToggle(
                'Maintenance Mode',
                'Temporarily disable public access to the marketplace',
                data['maintenanceMode'] ?? false,
                (val) => service.updateGeneralSetting('maintenanceMode', val),
              ),
              const Divider(height: 32),
              _buildSettingToggle(
                'Allow New Listings',
                'Enable or disable new product uploads from sellers',
                data['allowNewListings'] ?? true,
                (val) => service.updateGeneralSetting('allowNewListings', val),
              ),
              const Divider(height: 32),
              _buildSettingToggle(
                'Require ID Verification',
                'Force all sellers to be ID-verified before listing',
                data['requireIdVerification'] ?? false,
                (val) => service.updateGeneralSetting('requireIdVerification', val),
              ),
              const Divider(height: 32),
              _buildSettingInput(
                'Platform Commission (%)',
                'Set the percentage taken from each sale',
                data['commissionRate']?.toString() ?? '5',
                (val) => service.updateGeneralSetting('commissionRate', double.tryParse(val) ?? 5.0),
              ),
              const Divider(height: 32),
              _buildSectionHeader('Payment Gateways', Icons.payments_rounded),
              const SizedBox(height: 16),
              _buildSettingToggle(
                'Enable Credit/Debit Cards',
                'Allow users to pay using Visa, Mastercard, etc.',
                data['enableCards'] ?? true,
                (val) => service.updateGeneralSetting('enableCards', val),
              ),
              const Divider(height: 24),
              _buildSettingToggle(
                'Enable JazzCash',
                'Allow users to pay using JazzCash mobile wallet',
                data['enableJazzCash'] ?? true,
                (val) => service.updateGeneralSetting('enableJazzCash', val),
              ),
              const Divider(height: 24),
              _buildSettingToggle(
                'Enable EasyPaisa',
                'Allow users to pay using EasyPaisa mobile wallet',
                data['enableEasyPaisa'] ?? true,
                (val) => service.updateGeneralSetting('enableEasyPaisa', val),
              ),
              const Divider(height: 32),
              _buildSectionHeader('Privacy & Safety Features', Icons.shield_rounded),
              const SizedBox(height: 16),
              _buildSettingToggle(
                'Women Privacy Mode',
                'Enable privacy-by-default for female users (hide phone, location, gender)',
                data['enableWomenPrivacy'] ?? true,
                (val) => service.updateGeneralSetting('enableWomenPrivacy', val),
              ),
              const Divider(height: 24),
              _buildSettingToggle(
                'Anonymous Selling',
                'Allow sellers to list products without showing their name',
                data['enableAnonymousSelling'] ?? true,
                (val) => service.updateGeneralSetting('enableAnonymousSelling', val),
              ),
              const Divider(height: 24),
              _buildSettingToggle(
                'Female Support Team',
                'Enable dedicated female support agent contact option',
                data['enableFemaleSupport'] ?? true,
                (val) => service.updateGeneralSetting('enableFemaleSupport', val),
              ),
              const Divider(height: 24),
              _buildSettingToggle(
                'Chat Privacy Warnings',
                'Warn users when they share sensitive info (phone, CNIC, bank) in chat',
                data['enableChatPrivacyWarnings'] ?? true,
                (val) => service.updateGeneralSetting('enableChatPrivacyWarnings', val),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: (val) {
            onChanged(val);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title updated')),
            );
          },
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSettingInput(String title, String subtitle, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onSubmitted: (val) {
              onSave(val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title updated')),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDeleteAdmin(BuildContext context, QueryDocumentSnapshot admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Access'),
        content: Text('Are you sure you want to remove ${admin['email']} from the admin team?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              admin.reference.delete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  Widget _buildFancyActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.02),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          hoverColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Manage Now',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSystemLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('System Logs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<FirebaseService>(context, listen: false).getSystemLogs(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final timestamp = (doc['timestamp'] as Timestamp?)?.toDate();
                        return ListTile(
                          title: Text(doc['action']),
                          subtitle: Text('${doc['details']}\nBy: ${doc['adminEmail']}'),
                          trailing: Text(timestamp != null 
                            ? '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute}' 
                            : '...'),
                          isThreeLine: true,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
        ),
      ),
    );
  }

  void _showCMSEditor(BuildContext context, String docId, String title) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 900,
          height: 800,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text(
                        'Update the content displayed to users in the mobile app',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: Provider.of<FirebaseService>(context, listen: false).getCMSContent(docId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        if (controller.text.isEmpty) {
                          controller.text = data['content'] ?? '';
                        }
                      }
                      return TextField(
                        controller: controller,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: GoogleFonts.inter(height: 1.6, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Start writing your content here...',
                          contentPadding: const EdgeInsets.all(24),
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Discard Changes', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      await Provider.of<FirebaseService>(context, listen: false)
                          .updateCMSContent(docId, controller.text);
                      nav.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('$title updated successfully'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Publish Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPushNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.send_time_extension_rounded, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Broadcast Message', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This message will be sent to all active platform users immediately.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Notification Title',
                hintText: 'e.g., Special Weekend Offer!',
                labelStyle: GoogleFonts.inter(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message Body',
                hintText: 'Enter the content of your notification...',
                labelStyle: GoogleFonts.inter(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || bodyController.text.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(context);
              final firebaseService = Provider.of<FirebaseService>(context, listen: false);
              await firebaseService.sendBroadcastNotification(titleController.text, bodyController.text);
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Global notification dispatched!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send Broadcast'),
          ),
        ],
      ),
    );
  }

  void _showSafeMeetingLocations(BuildContext context) {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 700,
          height: 600,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Safe Meeting Locations', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold)),
                      Text('Manage public places for safe user transactions', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Location Name', hintText: 'e.g., Emporium Mall'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City', hintText: 'e.g., Lahore'))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty || cityCtrl.text.trim().isEmpty) return;
                      await Provider.of<FirebaseService>(context, listen: false).addDocument('safe_meeting_locations', {
                        'name': nameCtrl.text.trim(),
                        'city': cityCtrl.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      nameCtrl.clear();
                      cityCtrl.clear();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Add', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<FirebaseService>(context, listen: false).getCollectionStream('safe_meeting_locations'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) return Center(child: Text('No locations added yet', style: GoogleFonts.inter(color: AppColors.textSecondary)));
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(d['name'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          subtitle: Text('${d['city'] ?? ''}', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => docs[i].reference.delete(),
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
      ),
    );
  }

  void _showCategoryManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 900,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Global Categories',
                        style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Define the taxonomy and organization of the marketplace',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await Provider.of<FirebaseService>(context, listen: false).seedDefaultCategories();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All categories seeded!')),
                            );
                          }
                        },
                        icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                        label: const Text('Seed Defaults'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.accentGold),
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'EXISTING CATEGORIES',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 500,
                child: StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<FirebaseService>(context, listen: false).getCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final categories = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final doc = categories[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final subCategories = data['subCategories'] as List<dynamic>? ?? [];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    data['icon'] ?? '📁',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  data['name'] ?? '',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${subCategories.length} subcategories',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            children: [
                              ...subCategories.map((sub) {
                                final subData = sub as Map<String, dynamic>;
                                return ListTile(
                                  leading: Text(
                                    subData['icon'] ?? '📄',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  title: Text(
                                    subData['name'] ?? '',
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                );
                              }),
                            ],
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
      ),
    );
  }

  void _showBannerManagement(BuildContext context) {
    final urlController = TextEditingController();
    final linkController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promotional Banners',
                        style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Manage featured visual content for the user app',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: 'Enter Image URL...',
                        prefixIcon: const Icon(Icons.link_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: linkController,
                      decoration: InputDecoration(
                        hintText: 'Enter Destination URL (optional)...',
                        prefixIcon: const Icon(Icons.open_in_new_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (urlController.text.isNotEmpty) {
                            await Provider.of<FirebaseService>(context, listen: false)
                                .addBanner(urlController.text, linkController.text.isEmpty ? null : linkController.text);
                            urlController.clear();
                            linkController.clear();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Banner published successfully')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: const Text('Add Banner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'ACTIVE BANNERS',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 350,
                child: StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<FirebaseService>(context, listen: false).getBanners(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final banners = snapshot.data!.docs;
                    if (banners.isEmpty) {
                      return Center(
                        child: Text('No active banners', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                      );
                    }
                    return ListView.builder(
                      itemCount: banners.length,
                      itemBuilder: (context, index) {
                        final doc = banners[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: data['imageUrl'] ?? '',
                                width: 120,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[100],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
                                ),
                              ),
                            ),
                            title: Text('Banner ${index + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            subtitle: Text(data['imageUrl'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                              onPressed: () async {
                                await Provider.of<FirebaseService>(context, listen: false).deleteBanner(doc.id);
                              },
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
      ),
    );
  }
}
