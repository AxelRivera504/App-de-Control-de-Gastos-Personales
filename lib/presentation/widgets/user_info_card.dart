import 'package:flutter/material.dart';
import 'package:app_control_gastos_personales/config/theme/app_theme.dart';

class UserInfoCard extends StatelessWidget {
  final String userName;
  final String userId;
  final String userEmail;
  final bool isLoading;

  const UserInfoCard({
    super.key,
    required this.userName,
    required this.userId,
    required this.userEmail,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.verde,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 12),
        
        if (isLoading) ...[
          const CircularProgressIndicator(
            color: AppTheme.verde,
            strokeWidth: 2,
          ),
          const SizedBox(height: 8),
          const Text(
            'Cargando...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ] else ...[
          Text(
            userName,
            style: const TextStyle(
              color: AppTheme.verdeOscuro,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: $userId',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}