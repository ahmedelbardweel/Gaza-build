import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  danger,
  ghost,
  tonal,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
  }) : variant = AppButtonVariant.outline;

  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
  }) : variant = AppButtonVariant.danger;

  const AppButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.tonal({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.padding,
  }) : variant = AppButtonVariant.tonal;

  @override
  Widget build(BuildContext context) {
    final double computedHeight = height ?? _getHeightForSize(size);
    final double fontSize = _getFontSizeForSize(size);
    final effectivePadding = padding ?? _getPaddingForSize(size);

    final Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    Widget buttonWidget;

    switch (variant) {
      case AppButtonVariant.primary:
        buttonWidget = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            padding: effectivePadding,
            shape: AppTheme.roundedShape,
            minimumSize: Size(width ?? 0, computedHeight),
            elevation: 0,
          ),
          child: content,
        );
        break;

      case AppButtonVariant.secondary:
        buttonWidget = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.4),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            padding: effectivePadding,
            shape: AppTheme.roundedShape,
            minimumSize: Size(width ?? 0, computedHeight),
            elevation: 0,
          ),
          child: content,
        );
        break;

      case AppButtonVariant.outline:
        buttonWidget = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textMuted,
            padding: effectivePadding,
            shape: AppTheme.roundedShape,
            side: const BorderSide(color: AppColors.border, width: 1),
            minimumSize: Size(width ?? 0, computedHeight),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.danger:
        buttonWidget = FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            padding: effectivePadding,
            shape: AppTheme.roundedShape,
            minimumSize: Size(width ?? 0, computedHeight),
            elevation: 0,
          ),
          child: content,
        );
        break;

      case AppButtonVariant.ghost:
        buttonWidget = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textMuted,
            padding: effectivePadding,
            shape: AppTheme.roundedShape,
            minimumSize: Size(width ?? 0, computedHeight),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.tonal:
        buttonWidget = FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceVariant,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            disabledForegroundColor: AppColors.textMuted,
            padding: effectivePadding,
            shape: AppTheme.roundedShape,
            minimumSize: Size(width ?? 0, computedHeight),
            elevation: 0,
          ),
          child: content,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: computedHeight,
        child: buttonWidget,
      );
    }

    if (width != null) {
      return SizedBox(
        width: width,
        height: computedHeight,
        child: buttonWidget,
      );
    }

    return SizedBox(
      height: computedHeight,
      child: buttonWidget,
    );
  }

  double _getHeightForSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 34;
      case AppButtonSize.medium:
        return 42;
      case AppButtonSize.large:
        return 48;
    }
  }

  double _getFontSizeForSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return 12.5;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 15;
    }
  }

  EdgeInsetsGeometry _getPaddingForSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  Color _getLoadingColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return Colors.black;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return AppColors.primary;
      case AppButtonVariant.tonal:
        return AppColors.textPrimary;
    }
  }
}
