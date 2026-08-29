import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/core/constants/app_constants.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/theme/theme_cubit.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_text_field.dart';
import 'package:gaza_build/core/widgets/role_card.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  UserRole _selectedRole = UserRole.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp) {
      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              preferredRole: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                shape: AppTheme.roundedShape,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Quick Theme Toggle Top Bar
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: isDark ? 'التبديل إلى الوضع النهاري' : 'التبديل إلى الوضع الليلي',
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () => context.read<ThemeCubit>().toggleTheme(context),
                        ),
                      ),

                      // Brand Header
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'عَمّـار',
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                                letterSpacing: 2.0,
                              ),
                            ),
                            Text(
                              AppConstants.appTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card Container
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                        hasShadow: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Toggle Auth Mode
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: AppTheme.borderRadius,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _AuthTabButton(
                                      title: 'تسجيل الدخول',
                                      isSelected: !_isSignUp,
                                      onTap: () {
                                        if (_isSignUp) setState(() => _isSignUp = false);
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: _AuthTabButton(
                                      title: 'إنشاء حساب جديد',
                                      isSelected: _isSignUp,
                                      onTap: () {
                                        if (!_isSignUp) setState(() => _isSignUp = true);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Email Field
                            AppTextField(
                              label: 'البريد الإلكتروني',
                              hint: 'example@gazabuild.ps',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'يرجى إدخال البريد الإلكتروني';
                                }
                                if (!val.contains('@')) {
                                  return 'يرجى إدخال بريد إلكتروني صالح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Password Field
                            AppTextField(
                              label: 'كلمة المرور',
                              hint: '••••••••',
                              controller: _passwordController,
                              isPassword: true,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'يرجى إدخال كلمة المرور';
                                }
                                if (val.length < 6) {
                                  return 'كلمة المرور يجب أن لا تقل عن 6 خانات';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Role Selection (Only shown during Sign Up)
                            if (_isSignUp) ...[
                              Text(
                                'نوع الحساب في المنصة',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RoleCard(
                                roleKey: 'client',
                                title: 'صاحب مشروع (عميل)',
                                description: 'طلب تصاميم، نشر مشاريع، وتوظيف استشاريين',
                                isSelected: _selectedRole == UserRole.client,
                                accentColor: AppColors.clientRole,
                                onTap: () => setState(() => _selectedRole = UserRole.client),
                              ),
                              const SizedBox(height: 8),
                              RoleCard(
                                roleKey: 'engineer',
                                title: 'مهندس معماري / ديكور',
                                description: 'تقديم عروض، إسناد مهام للطلاب، وتوثيق المخططات',
                                isSelected: _selectedRole == UserRole.engineer,
                                accentColor: AppColors.engineerRole,
                                onTap: () => setState(() => _selectedRole = UserRole.engineer),
                              ),
                              const SizedBox(height: 8),
                              RoleCard(
                                roleKey: 'student',
                                title: 'طالب هندسة / مساعد',
                                description: 'تنفيذ مهام رسم 2D و3D وبناء معرض أعمال معتمد',
                                isSelected: _selectedRole == UserRole.student,
                                accentColor: AppColors.studentRole,
                                onTap: () => setState(() => _selectedRole = UserRole.student),
                              ),
                              const SizedBox(height: 8),
                              RoleCard(
                                roleKey: 'syndicate',
                                title: 'نقابة المهندسين (مدقق)',
                                description: 'اعتماد تراخيص المهندسين وتدقيق المخططات وحل النزعات',
                                isSelected: _selectedRole == UserRole.syndicate,
                                accentColor: AppColors.syndicateRole,
                                onTap: () => setState(() => _selectedRole = UserRole.syndicate),
                              ),
                              const SizedBox(height: 18),
                            ],

                            // Submit Button
                            AppButton.primary(
                              text: _isSignUp ? 'إنشاء الحساب ومتابعة' : 'تسجيل الدخول',
                              isLoading: isLoading,
                              isFullWidth: true,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Footer Note
                      Center(
                        child: Text(
                          'منصة عمار الرقمية - جميع الحقوق محفوظة لقطاع غزة © 2026',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AuthTabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _AuthTabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurfaceElevated : AppColors.surface)
              : Colors.transparent,
          borderRadius: AppTheme.borderRadius,
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
