import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.initialValue,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword || widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget? suffix;

    if (widget.isPassword) {
      suffix = TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          setState(() {
            _obscured = !_obscured;
          });
        },
        child: Text(
          _obscured ? 'إظهار' : 'إخفاء',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      );
    }

    final effectiveFill = widget.enabled
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final effectiveBorder = Theme.of(context).dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          key: widget.key,
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          style: TextStyle(
            fontSize: 14.5,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            helperMaxLines: 2,
            prefixIcon: widget.prefixIcon,
            suffixIcon: suffix ?? widget.suffixIcon,
            filled: true,
            fillColor: effectiveFill,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
            helperStyle: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
