import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: AppTheme.borderRadius,
              ),
              child: Text(
                'تنبيه',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 16),
              AppButton.primary(
                text: actionText!,
                size: AppButtonSize.small,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
