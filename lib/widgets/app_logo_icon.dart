import 'package:flutter/material.dart';

class AppLogoIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogoIcon({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.admin_panel_settings,
        size: size,
        color: color ?? Colors.white,
      ),
    );
  }
}
