import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool showNotifications;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationPressed;

  const NavigationHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showNotifications = false,
    this.onBackPressed,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: onBackPressed ?? () => context.pop(),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 24,
              ),
            )
          else
            const SizedBox(width: 24),
          
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          if (showNotifications)
            GestureDetector(
              onTap: onNotificationPressed,
              child: const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 24,
              ),
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }
}