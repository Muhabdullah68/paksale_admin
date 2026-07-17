import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../products/products_screen.dart';
import '../users/users_screen.dart';
import '../orders/orders_screen.dart';
import 'dashboard_home.dart';
import '../finance/finance_screen.dart';
import '../settings/settings_screen.dart';
import '../reports/reports_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  // Filter states
  ProductStatus? _productStatusFilter;
  bool? _productFeaturedFilter;
  SellerTier? _userTierFilter;

  void _navigateToProducts({ProductStatus? status, bool? featured}) {
    setState(() {
      _productStatusFilter = status;
      _productFeaturedFilter = featured;
    });
    _controller.selectIndex(1);
  }

  void _navigateToUsers({SellerTier? tier}) {
    setState(() {
      _userTierFilter = tier;
    });
    _controller.selectIndex(3);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      key: _key,
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(
                'QatarSale Admin',
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                onPressed: () => _key.currentState?.openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
      drawer: isDesktop ? null : _Sidebar(controller: _controller),
      body: Row(
        children: [
          if (isDesktop) _Sidebar(controller: _controller),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _TopBar(controller: _controller),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200), // Slightly faster for snappier feel
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        child: _buildScreen(_controller.selectedIndex),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardHome(
          onNavigateToProducts: _navigateToProducts,
          onNavigateToUsers: _navigateToUsers,
          onCardTap: (i) => _controller.selectIndex(i),
        );
      case 1:
        return ProductsScreen(
          key: ValueKey('products_$_productStatusFilter$_productFeaturedFilter'),
          initialStatus: _productStatusFilter,
          filterFeatured: _productFeaturedFilter,
        );
      case 2:
        return const OrdersScreen();
      case 3:
        return UsersScreen(
          key: ValueKey('users_$_userTierFilter'),
          initialTier: _userTierFilter,
        );
      case 4:
        return const ReportsScreen();
      case 5:
        return const FinanceScreen();
      case 6:
        return const SettingsScreen();
      default:
        return DashboardHome(
          onNavigateToProducts: _navigateToProducts,
          onNavigateToUsers: _navigateToUsers,
          onCardTap: (i) => _controller.selectIndex(i),
        );
    }
  }
}

class _TopBar extends StatelessWidget {
  final SidebarXController controller;
  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Text(
            _getTitle(controller.selectedIndex),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => controller.selectIndex(5),
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          const VerticalDivider(indent: 20, endIndent: 20, color: AppColors.divider),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Super Admin',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                'admin@qatarsale.com',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard Overview';
      case 1: return 'Inventory Management';
      case 2: return 'COD Orders';
      case 3: return 'User Directory';
      case 4: return 'Moderation Reports';
      case 5: return 'Financial Analytics';
      case 6: return 'System Settings';
      default: return 'QatarSale Admin';
    }
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.controller});
  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        width: 80,
        decoration: const BoxDecoration(color: AppColors.sidebarBackground),
        iconTheme: const IconThemeData(color: Colors.white54, size: 20),
        selectedIconTheme: const IconThemeData(color: AppColors.accentGold, size: 22),
        textStyle: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
        selectedTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 240,
        decoration: BoxDecoration(color: AppColors.sidebarBackground),
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      headerBuilder: (context, extended) {
        return Container(
          height: 120,
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: extended
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.admin_panel_settings, color: AppColors.accentGold, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'QATARSALE',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  )
                : const Icon(Icons.admin_panel_settings, color: AppColors.accentGold, size: 32),
          ),
        );
      },
      items: [
        SidebarXItem(icon: Icons.dashboard_rounded, label: 'Overview'),
        SidebarXItem(icon: Icons.inventory_2_rounded, label: 'Inventory'),
        SidebarXItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
        SidebarXItem(icon: Icons.group_rounded, label: 'Members'),
        SidebarXItem(icon: Icons.gavel_rounded, label: 'Reports'),
        SidebarXItem(icon: Icons.analytics_rounded, label: 'Finance'),
        SidebarXItem(icon: Icons.settings_applications_rounded, label: 'Settings'),
      ],
      footerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        FirebaseAuth.instance.signOut();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  if (extended) ...[
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Responsive {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;
}
