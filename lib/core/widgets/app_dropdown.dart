import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMatchingValue = items.any((item) => item.value == value);
    final effectiveValue = hasMatchingValue
        ? value
        : (items.isNotEmpty ? items.first.value : null);

    final effectiveFill = enabled
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final effectiveBorder = Theme.of(context).dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: effectiveValue,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              alignment: item.alignment,
              onTap: item.onTap,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 13.5,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: item.child,
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          style: TextStyle(
            fontSize: 13.5,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          borderRadius: AppTheme.borderRadius,
          dropdownColor: Theme.of(context).colorScheme.surface,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: effectiveFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: AppTheme.borderRadius,
              borderSide: BorderSide(color: effectiveBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.borderRadius,
              borderSide: BorderSide(color: effectiveBorder, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppTheme.borderRadius,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: AppTheme.borderRadius,
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: AppTheme.borderRadius,
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
            hintStyle: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
