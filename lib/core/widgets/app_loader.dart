import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;

  const AppLoader({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });

  const AppLoader.small({
    super.key,
    this.size = 22,
    this.color,
    this.message,
  });

  const AppLoader.large({
    super.key,
    this.size = 56,
    this.color,
    this.message,
  });

  static Widget fullScreen({
    BuildContext? context,
    String message = 'جاري التحميل والمزامنة مع منصة عمار...',
  }) {
    return _FullScreenLoader(message: message);
  }

  static Widget shimmerList({
    int count = 4,
    double height = 110,
  }) {
    return _ShimmerListLoader(count: count, height: height);
  }

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.color ??
        (isDark ? AppColors.primaryLight : AppColors.primary);

    Widget loader = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final angle = t * 2 * math.pi;
          final scale = 0.8 + 0.2 * math.sin(t * 2 * math.pi);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing glowing ring
              Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.0),
                        primaryColor.withValues(alpha: 0.2),
                        primaryColor.withValues(alpha: 0.8),
                        primaryColor,
                      ],
                      transform: GradientRotation(angle),
                    ),
                  ),
                ),
              ),

              // Inner cut-out mask
              Container(
                width: widget.size * 0.72,
                height: widget.size * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF121212) : Colors.white,
                ),
              ),

              // Rotating inner architectural diamond
              Transform.rotate(
                angle: -angle * 1.5,
                child: Container(
                  width: widget.size * 0.28,
                  height: widget.size * 0.28,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(widget.size * 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (widget.message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loader,
          const SizedBox(height: 12),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return loader;
  }
}

class _FullScreenLoader extends StatelessWidget {
  final String message;

  const _FullScreenLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceElevated.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: AppTheme.borderRadius,
          border: Border.all(
            color: isDark
                ? Theme.of(context).dividerColor
                : AppColors.primary.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoader.large(),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerListLoader extends StatefulWidget {
  final int count;
  final double height;

  const _ShimmerListLoader({required this.count, required this.height});

  @override
  State<_ShimmerListLoader> createState() => _ShimmerListLoaderState();
}

class _ShimmerListLoaderState extends State<_ShimmerListLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final opacity = 0.35 + (_animController.value * 0.45);
        final shimmerColor = isDark
            ? Color.fromRGBO(39, 39, 42, opacity)
            : Color.fromRGBO(241, 245, 249, opacity);

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          itemCount: widget.count,
          itemBuilder: (context, index) {
            return Container(
              height: widget.height,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: AppTheme.borderRadius,
                border: Border.all(
                  color: isDark ? Theme.of(context).dividerColor : AppColors.border,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
