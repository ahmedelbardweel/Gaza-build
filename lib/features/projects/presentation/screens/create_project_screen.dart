import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gaza_build/core/constants/app_constants.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_dropdown.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/core/widgets/app_text_field.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_event.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_state.dart';
import 'package:gaza_build/features/projects/models/project_model.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController(text: '120');
  final _budgetController = TextEditingController(text: '3500');
  final _addressController = TextEditingController();

  String _selectedProjectType = AppConstants.clientProjectTypes.first;
  String _selectedStyle = AppConstants.architecturalStyles.first;
  String _selectedCity = AppConstants.gazaCities.first;
  bool _photosAttached = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = context.read<AuthBloc>().state.user;
    if (currentUser == null) return;

    final project = Project(
      id: '',
      clientId: currentUser.id,
      clientName: currentUser.fullName.isNotEmpty ? currentUser.fullName : 'صاحب المشروع',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      projectType: _selectedProjectType,
      areaM2: double.tryParse(_areaController.text.trim()) ?? 100.0,
      approximateBudgetUsd: double.tryParse(_budgetController.text.trim()) ?? 2000.0,
      preferredStyle: _selectedStyle,
      city: _selectedCity,
      detailedAddress: _addressController.text.trim(),
      sitePhotos: _photosAttached ? const ['attached_site_photo_1.jpg', 'attached_site_photo_2.jpg'] : const [],
      status: ProjectStatus.bidding,
      createdAt: DateTime.now(),
    );

    context.read<ProjectsBloc>().add(CreateProjectRequested(project));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectsBloc, ProjectsState>(
      listener: (context, state) {
        if (state.status == ProjectsStatus.actionSuccess && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              shape: AppTheme.roundedShape,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        } else if (state.status == ProjectsStatus.error && state.errorMessage != null) {
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
      child: AppScaffold(
        title: 'طرح طلب مشروع ذكي',
        showBackButton: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      title: 'تفاصيل المشروع والاحتياجات الهندسية',
                      subtitle: 'املأ البيانات لتصل للمهندسين وتتلقى عروض الأسعار والمودبورد',
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            label: 'عنوان المشروع *',
                            hint: 'مثال: إعادة تأهيل وترميم صالون ومطبخ منزل متضرر',
                            controller: _titleController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'يرجى إدخال عنوان للمشروع';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          AppDropdown<String>(
                            label: 'نوع المشروع أو الخدمة المطلوبة *',
                            value: _selectedProjectType,
                            items: AppConstants.clientProjectTypes.map((type) {
                              return DropdownMenuItem(value: type, child: Text(type));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedProjectType = val);
                            },
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'المساحة التقريبية (م²) *',
                                  hint: '120',
                                  controller: _areaController,
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'المساحة مطلوبة';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppTextField(
                                  label: 'الميزانية التقديرية (\$) *',
                                  hint: '3500',
                                  controller: _budgetController,
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'الميزانية مطلوبة';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          AppDropdown<String>(
                            label: 'النمط المعماري المفضل *',
                            value: _selectedStyle,
                            items: AppConstants.architecturalStyles.map((style) {
                              return DropdownMenuItem(value: style, child: Text(style));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStyle = val);
                            },
                          ),
                          const SizedBox(height: 12),

                          AppDropdown<String>(
                            label: 'المدينة / المنطقة في غزة *',
                            value: _selectedCity,
                            items: AppConstants.gazaCities.map((city) {
                              return DropdownMenuItem(value: city, child: Text(city));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCity = val);
                            },
                          ),
                          const SizedBox(height: 12),

                          AppTextField(
                            label: 'العنوان التفصيلي للموقع *',
                            hint: 'الشارع، الحي، أقرب معلم معروف...',
                            controller: _addressController,
                          ),
                          const SizedBox(height: 12),

                          AppTextField(
                            label: 'الوصف وشرح المتطلبات *',
                            hint: 'اشرح حالة المكان بالتفصيل، ما ترغب بتغييره أو ترميمه...',
                            controller: _descriptionController,
                            maxLines: 4,
                            validator: (val) {
                              if (val == null || val.trim().length < 10) {
                                return 'يرجى كتابة وصف وافٍ للمشروع (10 أحرف على الأقل)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Attach Photos Simulator
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: AppTheme.borderRadius,
                              border: Border.all(
                                color: _photosAttached ? AppColors.success : Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _photosAttached
                                            ? 'تم إرفاق صور واقع الموقع الحالي (2 صور)'
                                            : 'إرفاق صور لواقع الموقع الحالي',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _photosAttached
                                              ? AppColors.success
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'تساعد المهندسين في تقديم Mood Board أدق وعرض سعر حقيقي',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkTextMuted
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppButton.outline(
                                  text: _photosAttached ? 'تغيير' : 'إرفاق صور',
                                  size: AppButtonSize.small,
                                  onPressed: () {
                                    setState(() => _photosAttached = !_photosAttached);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    BlocBuilder<ProjectsBloc, ProjectsState>(
                      builder: (context, state) {
                        return AppButton.primary(
                          text: 'نشر المشروع وتلقي العروض الهندسية',
                          size: AppButtonSize.large,
                          isFullWidth: true,
                          isLoading: state.status == ProjectsStatus.loading,
                          onPressed: _submit,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
