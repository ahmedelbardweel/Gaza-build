import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppChipSelector<T> extends StatelessWidget {
  final String? label;
  final List<T> options;
  final List<T> selectedValues;
  final String Function(T) labelBuilder;
  final ValueChanged<List<T>> onChanged;
  final bool isMultiSelect;
  final bool wrap;
  final String? helperText;

  const AppChipSelector({
    super.key,
    this.label,
    required this.options,
    required this.selectedValues,
    required this.labelBuilder,
    required this.onChanged,
    this.isMultiSelect = true,
    this.wrap = true,
    this.helperText,
  });

  void _onChipTapped(T item) {
    if (isMultiSelect) {
      final updated = List<T>.from(selectedValues);
      if (updated.contains(item)) {
        updated.remove(item);
      } else {
        updated.add(item);
      }
      onChanged(updated);
    } else {
      onChanged([item]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chips = options.map((item) {
      final isSelected = selectedValues.contains(item);
      final text = labelBuilder(item);

      final selectedBg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer;
      final unselectedBg = isDark ? AppColors.darkSurfaceVariant : Theme.of(context).colorScheme.surface;
      final borderColor = isSelected ? AppColors.primary : Theme.of(context).dividerColor;
      final textColor = isSelected
          ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
          : Theme.of(context).colorScheme.onSurface;

      return InkWell(
        onTap: () => _onChipTapped(item),
        borderRadius: AppTheme.borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: AppTheme.borderRadius,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (wrap)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: chips
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: c,
                      ))
                  .toList(),
            ),
          ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
