import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/core/theme/theme_cubit.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_event.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_badge.dart';
import 'app_dialog.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final BaseProfile? userProfile;
  final bool showBackButton;
  final bool showUserRoleHeader;
  final PreferredSizeWidget? bottomAppBar;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final Color? appBarForegroundColor;
  final Color? systemNavigationBarColor;
  final bool safeAreaBottom;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.bottomNavigationBar,
    this.userProfile,
    this.showBackButton = false,
    this.showUserRoleHeader = false,
    this.bottomAppBar,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.appBarForegroundColor,
    this.systemNavigationBarColor,
    this.safeAreaBottom = false,
  });

  void _showAccountSheet(BuildContext context, BaseProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName.isNotEmpty ? profile.fullName : 'مستخدم منصة عمار',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppBadge.role(profile.role.name),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppTheme.borderRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المحافظة المسجلة:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      profile.city.isNotEmpty ? profile.city : 'غزة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Theme Switcher Section
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, currentMode) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: AppTheme.borderRadius,
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'مظهر التطبيق (الثيم)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _themeOption(
                              context: context,
                              title: 'نهاري',
                              icon: Icons.light_mode_rounded,
                              isSelected: currentMode == ThemeMode.light,
                              onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.light),
                            ),
                            const SizedBox(width: 8),
                            _themeOption(
                              context: context,
                              title: 'ليلي',
                              icon: Icons.dark_mode_rounded,
                              isSelected: currentMode == ThemeMode.dark,
                              onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.dark),
                            ),
                            const SizedBox(width: 8),
                            _themeOption(
                              context: context,
                              title: 'تلقائي',
                              icon: Icons.settings_brightness_rounded,
                              isSelected: currentMode == ThemeMode.system,
                              onTap: () => context.read<ThemeCubit>().setThemeMode(ThemeMode.system),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              AppButton.danger(
                text: 'تسجيل الخروج من الحساب',
                size: AppButtonSize.medium,
                isFullWidth: true,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final confirm = await AppDialog.confirm(
                    context: context,
                    title: 'تسجيل الخروج',
                    message: 'هل أنت متأكد من رغبتك في تسجيل الخروج من المنصة؟',
                    confirmText: 'تسجيل الخروج',
                    isDanger: true,
                  );
                  if (confirm == true && context.mounted) {
                    context.read<AuthBloc>().add(const AuthSignOutRequested());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer;
    final unselectedBg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: AppTheme.borderRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    final effectiveAppBarBg = appBarBackgroundColor ?? Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final effectiveAppBarFg = appBarForegroundColor ?? Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onSurface;
    final isWhiteHeader = effectiveAppBarFg == Colors.white;
    final navBarColor = systemNavigationBarColor ?? Theme.of(context).colorScheme.surface;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isWhiteHeader || isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: navBarColor,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: effectiveBg,
        appBar: AppBar(
          backgroundColor: effectiveAppBarBg,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: const Border(),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: effectiveAppBarFg,
            ),
          ),
          centerTitle: false,
          titleSpacing: 10,
          automaticallyImplyLeading: false,
          leading: showBackButton
              ? TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    'رجوع',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isWhiteHeader ? Colors.white : AppColors.primary,
                    ),
                  ),
                )
              : null,
          bottom: bottomAppBar,
          actions: [
            // Quick Theme Toggle
            IconButton(
              tooltip: isDark ? 'التبديل إلى الوضع النهاري' : 'التبديل إلى الوضع الليلي',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                size: 20,
                color: effectiveAppBarFg,
              ),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(context),
            ),
            if (actions != null) ...actions!,
            if (userProfile != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InkWell(
                  onTap: () => _showAccountSheet(context, userProfile!),
                  borderRadius: AppTheme.borderRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: effectiveAppBarFg == Colors.white
                          ? Colors.white.withValues(alpha: 0.15)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: AppTheme.borderRadius,
                      border: Border.all(
                        color: effectiveAppBarFg == Colors.white
                            ? Colors.white.withValues(alpha: 0.25)
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      'الحساب',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: effectiveAppBarFg,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          bottom: safeAreaBottom,
          child: Column(
            children: [
              if (showUserRoleHeader && userProfile != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.8),
                    ),
                  ),
                  child: Row(
                    children: [
                      AppBadge.role(userProfile!.role.name),
                      const SizedBox(width: 8),
                      if (userProfile!.role != UserRole.client)
                        AppBadge.verification(userProfile!.verificationStatus.name),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: AppTheme.borderRadius,
                        ),
                        child: Text(
                          userProfile!.city.isNotEmpty ? userProfile!.city : 'غزة',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: body),
            ],
          ),
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
