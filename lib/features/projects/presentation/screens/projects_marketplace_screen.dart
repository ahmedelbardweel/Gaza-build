import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_dialog.dart';
import 'package:gaza_build/core/widgets/app_empty_state.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/core/widgets/app_text_field.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_event.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_state.dart';
import 'package:gaza_build/features/projects/models/project_model.dart';

class ProjectsMarketplaceScreen extends StatefulWidget {
  const ProjectsMarketplaceScreen({super.key});

  @override
  State<ProjectsMarketplaceScreen> createState() => _ProjectsMarketplaceScreenState();
}

class _ProjectsMarketplaceScreenState extends State<ProjectsMarketplaceScreen> {
  String? _selectedCityFilter;

  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(const LoadProjectsRequested());
  }

  void _showSubmitBidDialog(BuildContext context, Project project) {
    final priceController = TextEditingController(text: '${(project.approximateBudgetUsd * 0.9).toInt()}');
    final daysController = TextEditingController(text: '20');
    final msgController = TextEditingController();
    final moodBoardController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    AppDialog.showAppBottomSheet(
      context: context,
      title: 'تقديم عرض هندسي: ${project.title}',
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'السعر المقترح (\$ USD) *',
                      hint: '3000',
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'السعر مطلوب';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      label: 'مدة التنفيذ (أيام) *',
                      hint: '20',
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'المدة مطلوبة';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'رسالة العرض والمنهجية الفنية *',
                hint: 'اشرح للعميل رؤيتك الهندسية وكيف ستستغل المساحة والمواد المتاحة في غزة...',
                controller: msgController,
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().length < 8) return 'يرجى كتابة رسالة توضيحية للعرض';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'المقترح البصري الأولي (Mood Board Concept)',
                hint: 'وصف باليتة الألوان، الخامات المقترحة (حجر، جبس، خشب)، ونوعية الإنارة...',
                controller: moodBoardController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              AppButton.primary(
                text: 'إرسال العرض للعميل',
                size: AppButtonSize.large,
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  final currentUser = context.read<AuthBloc>().state.user;
                  final bid = ProjectBid(
                    id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
                    projectId: project.id,
                    engineerId: currentUser?.id ?? 'eng_curr',
                    engineerName: currentUser?.fullName.isNotEmpty == true ? currentUser!.fullName : 'مهندس معتمد',
                    proposedPriceUsd: double.tryParse(priceController.text.trim()) ?? 3000.0,
                    estimatedDurationDays: int.tryParse(daysController.text.trim()) ?? 20,
                    proposalMessage: msgController.text.trim(),
                    moodBoardDescription: moodBoardController.text.trim(),
                    createdAt: DateTime.now(),
                  );

                  context.read<ProjectsBloc>().add(SubmitBidRequested(bid));
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'سوق مشاريع الإعمار والديكور',
      showBackButton: true,
      body: BlocConsumer<ProjectsBloc, ProjectsState>(
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
          }
        },
        builder: (context, state) {
          final openProjects = state.projects.where((p) {
            if (p.status != ProjectStatus.bidding) return false;
            if (_selectedCityFilter != null && !p.city.contains(_selectedCityFilter!)) return false;
            return true;
          }).toList();

          return Column(
            children: [
              // Header description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: Theme.of(context).colorScheme.surface,
                child: Text(
                  'المشاريع المتاحة لتلقي العروض (${openProjects.length} مشروع)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),

              Expanded(
                child: openProjects.isEmpty
                    ? const AppEmptyState(
                        title: 'لا توجد مشاريع جديدة حالياً',
                        message: 'يتم إضافة طلبات إعادة الإعمار والتشطيب بشكل دوري من أصحاب المنازل والمنشآت.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        itemCount: openProjects.length,
                        itemBuilder: (context, index) {
                          final project = openProjects[index];
                          final isDark = Theme.of(context).brightness == Brightness.dark;

                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            title: project.title,
                            subtitle: '${project.city} • ${project.projectType}',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                                borderRadius: AppTheme.borderRadius,
                              ),
                              child: Text(
                                '\$${project.approximateBudgetUsd.toInt()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                                ),
                              ),
                            ),
                            footer: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المالك: ${project.clientName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                AppButton.primary(
                                  text: 'تقديم عرض',
                                  size: AppButtonSize.small,
                                  onPressed: () => _showSubmitBidDialog(context, project),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _tag(context, '${project.areaM2.toInt()} م²'),
                                    const SizedBox(width: 6),
                                    _tag(context, project.preferredStyle.split(' ').first),
                                    const SizedBox(width: 6),
                                    _tag(context, '${project.bids.length} عروض'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tag(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppTheme.borderRadius,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
