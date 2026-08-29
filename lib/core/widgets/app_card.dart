import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget? child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool hasShadow;

  const AppCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.footer,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = backgroundColor ?? Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final effectiveBorder = borderColor ?? Theme.of(context).dividerColor;

    final hasHeader = title != null || subtitle != null || leading != null || trailing != null;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
          if (child != null) const SizedBox(height: 12),
        ],
        ?child,
        if (footer != null) ...[
          const SizedBox(height: 12),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 10),
          footer!,
        ],
      ],
    );

    Widget cardWidget = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: effectiveBorder, width: borderWidth),
        boxShadow: hasShadow && !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: content,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadius,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
