import 'package:flutter/material.dart';

class ClientAvatar extends StatelessWidget {
  final String initials;
  final String color;
  final double size;

  const ClientAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _parseColor(color);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withAlpha(40),
        shape: BoxShape.circle,
        border: Border.all(color: bgColor.withAlpha(120), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: bgColor,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }
}
