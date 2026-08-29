import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

abstract final class AppDialog {
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDanger = false,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top grab bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      text: cancelText,
                      size: AppButtonSize.medium,
                      isFullWidth: true,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: isDanger
                        ? AppButton.danger(
                            text: confirmText,
                            size: AppButtonSize.medium,
                            isFullWidth: true,
                            onPressed: () => Navigator.of(ctx).pop(true),
                          )
                        : AppButton.primary(
                            text: confirmText,
                            size: AppButtonSize.medium,
                            isFullWidth: true,
                            onPressed: () => Navigator.of(ctx).pop(true),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> showCustom<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Divider(height: 16, color: Theme.of(context).dividerColor),
              SingleChildScrollView(child: content),
              if (actions != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> showAppBottomSheet<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  ?trailing,
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 16, color: Theme.of(context).dividerColor),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
