import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum BadgeType {
  role,
  verification,
  status,
  custom,
}

class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isSmall;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isSmall = false,
  });

  // Role badges
  factory AppBadge.role(String role) {
    Color bg;
    Color fg;
    String text;

    switch (role.toLowerCase()) {
      case 'engineer':
        bg = AppColors.primaryContainer;
        fg = AppColors.primary;
        text = 'مهندس ديكور / معماري';
        break;
      case 'syndicate':
        bg = const Color(0x25A855F7);
        fg = const Color(0xFFC084FC);
        text = 'نقابة المهندسين';
        break;
      case 'student':
        bg = const Color(0x25F97316);
        fg = const Color(0xFFFB923C);
        text = 'طالب هندسة / مساعد';
        break;
      case 'client':
      default:
        bg = const Color(0x253B82F6);
        fg = const Color(0xFF60A5FA);
        text = 'صاحب مشروع / عميل';
        break;
    }

    return AppBadge(
      label: text,
      backgroundColor: bg,
      textColor: fg,
      borderColor: fg.withValues(alpha: 0.35),
    );
  }

  // Verification status badge
  factory AppBadge.verification(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'verified':
        bg = const Color(0x2516A34A);
        fg = const Color(0xFF4ADE80);
        text = 'معتمد وموثق';
        break;
      case 'pending':
        bg = const Color(0x25EAB308);
        fg = const Color(0xFFFDE047);
        text = 'قيد مراجعة النقابة';
        break;
      case 'rejected':
        bg = const Color(0x25DC2626);
        fg = const Color(0xFFF87171);
        text = 'مرفوض - يلزم تعديل';
        break;
      case 'unsubmitted':
      default:
        bg = const Color(0x2064748B);
        fg = const Color(0xFF94A3B8);
        text = 'البروفايل غير مكتمل';
        break;
    }

    return AppBadge(
      label: text,
      backgroundColor: bg,
      textColor: fg,
      borderColor: fg.withValues(alpha: 0.35),
    );
  }

  // Project / Task Status
  factory AppBadge.status(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status.toLowerCase()) {
      case 'open':
      case 'bidding':
        bg = const Color(0x250284C7);
        fg = const Color(0xFF38BDF8);
        text = 'استقبال العروض';
        break;
      case 'in_progress':
      case 'inprogress':
      case 'ongoing':
        bg = AppColors.primaryContainer;
        fg = AppColors.primary;
        text = 'قيد التنفيذ';
        break;
      case 'under_review':
      case 'underreview':
        bg = const Color(0x25EAB308);
        fg = const Color(0xFFFDE047);
        text = 'قيد المراجعة والتدقيق';
        break;
      case 'completed':
      case 'done':
        bg = const Color(0x2516A34A);
        fg = const Color(0xFF4ADE80);
        text = 'مكتمل ومعتمد';
        break;
      case 'disputed':
        bg = const Color(0x25DC2626);
        fg = const Color(0xFFF87171);
        text = 'نزاع لدى النقابة';
        break;
      case 'available':
        bg = const Color(0x2516A34A);
        fg = const Color(0xFF4ADE80);
        text = 'مهمة متاحة للطلاب';
        break;
      case 'draft':
        bg = const Color(0x2064748B);
        fg = const Color(0xFF94A3B8);
        text = 'مسودة';
        break;
      default:
        bg = const Color(0x2064748B);
        fg = const Color(0xFF94A3B8);
        text = status;
        break;
    }

    return AppBadge(
      label: text,
      backgroundColor: bg,
      textColor: fg,
      borderColor: fg.withValues(alpha: 0.35),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final effectiveFg = textColor ?? Theme.of(context).colorScheme.onSurface;
    final effectiveBorder = borderColor ?? effectiveFg.withValues(alpha: 0.2);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: effectiveBorder, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: effectiveFg,
          fontSize: isSmall ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
