import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String get _label => status[0].toUpperCase() + status.substring(1);
}

class TierBadge extends StatelessWidget {
  final String tier;

  const TierBadge({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _tierInfo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            tier[0].toUpperCase() + tier.substring(1),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) get _tierInfo {
    switch (tier) {
      case 'free':
        return (Colors.grey, '🆓');
      case 'standard':
        return (AppColors.primary, '⭐');
      case 'premium':
        return (AppColors.pending, '💎');
      case 'enterprise':
        return (AppColors.donation, '🏢');
      default:
        return (Colors.grey, '—');
    }
  }
}
