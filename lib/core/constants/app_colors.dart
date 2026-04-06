import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const secondary = Color(0xFF10B981);
  static const secondaryLight = Color(0xFF34D399);

  // Semantic
  static const income = Color(0xFF10B981);
  static const expense = Color(0xFFEF4444);
  static const donation = Color(0xFFA855F7);
  static const pending = Color(0xFFF59E0B);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Light Mode Backgrounds
  static const backgroundLight = Color(0xFFF9FAFB);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF3F4F6);

  // Dark Mode Backgrounds
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);
  static const surfaceVariantDark = Color(0xFF334155);

  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textPrimaryDark = Color(0xFFF9FAFB);
  static const textSecondaryDark = Color(0xFF94A3B8);

  // Status colors map
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return income;
      case 'paused':
        return pending;
      case 'cancelled':
        return expense;
      case 'pending':
        return pending;
      case 'completed':
        return success;
      case 'failed':
        return expense;
      case 'refunded':
        return warning;
      case 'lead':
        return primary;
      case 'inactive':
        return textSecondary;
      case 'churned':
        return expense;
      default:
        return textSecondary;
    }
  }

  // Node type colors
  static Color nodeTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
      case 'client':
      case 'service':
      case 'subscription':
        return income;
      case 'expense':
        return expense;
      case 'donation':
        return donation;
      case 'root':
        return primary;
      default:
        return primary;
    }
  }

  // Transaction type colors
  static Color transactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return income;
      case 'expense':
        return expense;
      case 'donation':
        return donation;
      case 'transfer':
        return pending;
      default:
        return textSecondary;
    }
  }
}
