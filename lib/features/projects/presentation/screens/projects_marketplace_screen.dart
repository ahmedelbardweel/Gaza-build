import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_dialog.dart';
import 'package:gaza_build/core/widgets/app_empty_state.dart';
import 'package:gaza_build/core/widgets/app_loader.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultPrice = (project.approximateBudgetUsd > 0
            ? project.approximateBudgetUsd * 0.9
            : 3000.0)
        .toInt();
    final priceController = TextEditingController(text: '$defaultPrice');
    final daysController = TextEditingController(text: '20');
    final msgController = TextEditingController();
    final moodBoardController = TextEditingController();

    final List<_MilestoneDraft> drafts = [
      _MilestoneDraft(
        title: 'المخططات التنفيذية 2D وتوزيع المساحات',
        amount: (defaultPrice * 0.20).roundToDouble(),
      ),
      _MilestoneDraft(
        title: 'اللقطات ثلاثية الأبعاد 3D ولوحات الخامات (Mood Boards)',
        amount: (defaultPrice * 0.35).roundToDouble(),
      ),
      _MilestoneDraft(
        title: 'جدول الكميات والمواصفات (BOQ) وتوريد المواد',
        amount: (defaultPrice * 0.25).roundToDouble(),
      ),
      _MilestoneDraft(
        title: 'الإشراف والتنفيذ والتسليم النهائي للموقع',
        amount: (defaultPrice * 0.20).roundToDouble(),
      ),
    ];

    final formKey = GlobalKey<FormState>();

    AppDialog.showAppBottomSheet(
      context: context,
      title: 'تقديم عرض هندسي مخصص: ${project.title}',
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final totalPrice =
              double.tryParse(priceController.text.trim()) ?? (defaultPrice.toDouble());

          double milestonesSum = 0;
          for (final d in drafts) {
            milestonesSum += double.tryParse(d.amountController.text.trim()) ?? 0;
          }

          final isBalanced = (milestonesSum - totalPrice).abs() < 1.0;

          return Form(
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
                          onChanged: (val) {
                            final p = double.tryParse(val) ?? 0;
                            if (p > 0 && drafts.isNotEmpty) {
                              setDialogState(() {
                                // Auto distribute proportionally
                                final share = (p / drafts.length).roundToDouble();
                                for (final d in drafts) {
                                  d.amountController.text = share.toInt().toString();
                                }
                              });
                            } else {
                              setDialogState(() {});
                            }
                          },
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
                    maxLines: 2,
                    validator: (val) {
                      if (val == null || val.trim().length < 5) {
                        return 'يرجى كتابة رسالة توضيحية للعرض';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    label: 'المقترح البصري الأولي (Mood Board Concept)',
                    hint: 'وصف باليتة الألوان، الخامات المقترحة، ونوعية الإنارة...',
                    controller: moodBoardController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // ─── Milestone Breakdown Section ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مراحل الإنجاز والدفعات المالية (${drafts.length})',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(ctx).colorScheme.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            drafts.add(
                              _MilestoneDraft(
                                title: 'مرحلة ${drafts.length + 1}',
                                amount: 500,
                              ),
                            );
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded,
                            size: 16, color: AppColors.primary),
                        label: const Text(
                          'إضافة مرحلة',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'حدد مسمى كل مرحلة والمبلغ المالي المخصص لها ليتم ربطه بالضمان المالي (Escrow)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // List of editable milestones
                  ...drafts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final draft = entry.value;
                    final draftAmount =
                        double.tryParse(draft.amountController.text.trim()) ?? 0;
                    final percentage = totalPrice > 0
                        ? ((draftAmount / totalPrice) * 100).toStringAsFixed(0)
                        : '0';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : Theme.of(ctx).colorScheme.surfaceContainerHighest,
                        borderRadius: AppTheme.borderRadius,
                        border: Border.all(
                          color: Theme.of(ctx).dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkPrimaryContainer
                                      : AppColors.primaryContainer,
                                  borderRadius: AppTheme.borderRadius,
                                ),
                                child: Text(
                                  'المرحلة ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'النسبة من العقد: $percentage%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                              if (drafts.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setDialogState(() {
                                      drafts.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  label: 'مسمى المرحلة *',
                                  hint: 'المخططات التنفيذية 2D',
                                  controller: draft.titleController,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'مطلوب';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  label: 'المبلغ (\$ USD) *',
                                  hint: '750',
                                  controller: draft.amountController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setDialogState(() {}),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'مطلوب';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  // Balance validation summary card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isBalanced
                          ? (isDark
                              ? AppColors.darkSuccessContainer
                              : AppColors.successContainer.withValues(alpha: 0.5))
                          : (isDark
                              ? AppColors.darkErrorContainer
                              : AppColors.errorContainer.withValues(alpha: 0.5)),
                      borderRadius: AppTheme.borderRadius,
                      border: Border.all(
                        color: isBalanced ? AppColors.success : AppColors.error,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مجموع المراحل: \$${milestonesSum.toInt()} / \$${totalPrice.toInt()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isBalanced
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        if (!isBalanced)
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                final share = (totalPrice / drafts.length).roundToDouble();
                                for (final d in drafts) {
                                  d.amountController.text = share.toInt().toString();
                                }
                              });
                            },
                            child: const Text(
                              'موازنة تلقائية',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  AppButton.primary(
                    text: 'إرسال العرض وجدول الدفعات للعميل',
                    size: AppButtonSize.large,
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      final currentUser = context.read<AuthBloc>().state.user;
                      final proposedMilestones = drafts.map((d) {
                        final amount =
                            double.tryParse(d.amountController.text.trim()) ?? 0;
                        final weight = totalPrice > 0
                            ? ((amount / totalPrice) * 100).round()
                            : 25;
                        return ProjectMilestone(
                          id: '',
                          title: d.titleController.text.trim(),
                          description:
                              'تسليم واعتماد مخرجات ${d.titleController.text.trim()}',
                          percentageWeight: weight,
                          paymentAmountUsd: amount,
                        );
                      }).toList();

                      final bid = ProjectBid(
                        id: '',
                        projectId: project.id,
                        engineerId: currentUser?.id ?? '',
                        engineerName: currentUser?.fullName.isNotEmpty == true
                            ? currentUser!.fullName
                            : 'مهندس معتمد',
                        proposedPriceUsd: totalPrice,
                        estimatedDurationDays:
                            int.tryParse(daysController.text.trim()) ?? 20,
                        proposalMessage: msgController.text.trim(),
                        moodBoardDescription: moodBoardController.text.trim(),
                        proposedMilestones: proposedMilestones,
                        createdAt: DateTime.now(),
                      );

                      context.read<ProjectsBloc>().add(SubmitBidRequested(bid));
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'سوق مشاريع الإعمار والديكور',
      showBackButton: true,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProjectsBloc>().add(const LoadProjectsRequested());
        },
        child: BlocConsumer<ProjectsBloc, ProjectsState>(
          listener: (context, state) {
            if (state.status == ProjectsStatus.actionSuccess &&
                state.successMessage != null) {
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
            if (state.status == ProjectsStatus.loading && state.projects.isEmpty) {
              return const Center(
                child: AppLoader(
                  message: 'جاري تحديث واسترجاع المشاريع المتاحة من السحابة...',
                ),
              );
            }

            final openProjects = state.projects.where((p) {
              if (p.status != ProjectStatus.bidding) return false;
              if (_selectedCityFilter != null &&
                  !p.city.contains(_selectedCityFilter!)) {
                return false;
              }
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

class _MilestoneDraft {
  final TextEditingController titleController;
  final TextEditingController amountController;

  _MilestoneDraft({
    required String title,
    required double amount,
  })  : titleController = TextEditingController(text: title),
        amountController =
            TextEditingController(text: amount.toInt().toString());
}
