import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class RoleCard extends StatelessWidget {
  final String roleKey;
  final String title;
  final String description;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const RoleCard({
    super.key,
    required this.roleKey,
    required this.title,
    required this.description,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveAccent = accentColor ?? AppColors.primary;

    final bgColor = isSelected
        ? effectiveAccent.withValues(alpha: isDark ? 0.15 : 0.08)
        : (isDark ? AppColors.darkSurface : Theme.of(context).colorScheme.surface);

    final borderColor = isSelected
        ? effectiveAccent
        : Theme.of(context).dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppTheme.borderRadius,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? effectiveAccent : Theme.of(context).dividerColor,
                borderRadius: AppTheme.borderRadius,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? effectiveAccent : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: AppTheme.borderRadius,
              ),
              child: Text(
                isSelected ? 'محدد' : 'اختيار',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.black
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
