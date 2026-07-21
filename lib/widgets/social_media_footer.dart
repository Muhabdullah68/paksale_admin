
import 'dart:math';
import 'package:flutter/material.dart';

class SocialMediaFooter extends StatelessWidget {
  const SocialMediaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final socialMedia = [
      {'name': 'TikTok', 'url': 'https://www.tiktok.com'},
      {'name': 'Instagram', 'url': 'https://www.instagram.com'},
      {'name': 'Snapchat', 'url': 'https://www.snapchat.com'},
      {'name': 'YouTube', 'url': 'https://www.youtube.com'},
      {'name': 'X', 'url': 'https://twitter.com'},
      {'name': 'Facebook', 'url': 'https://www.facebook.com'},
      {'name': 'LinkedIn', 'url': 'https://www.linkedin.com'},
    ];

    final shuffled = List.from(socialMedia)..shuffle(Random());

    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Text(
            'Are you following us?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: shuffled.map((social) {
              return InkWell(
                onTap: () {
                  // TODO: Implement URL launching
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Text(
                    social['name']!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

