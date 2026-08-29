import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_dialog.dart';
import 'package:gaza_build/core/widgets/app_empty_state.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_event.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_state.dart';
import 'package:gaza_build/features/projects/models/project_model.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;
  final Project? initialProject;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectsBloc, ProjectsState>(
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
        final project = state.projects.firstWhere(
          (p) => p.id == projectId,
          orElse: () =>
              initialProject ??
              Project(
                id: '',
                clientId: '',
                clientName: '',
                title: 'تفاصيل المشروع',
                description: '',
                projectType: '',
                areaM2: 0,
                approximateBudgetUsd: 0,
                preferredStyle: '',
                city: '',
                createdAt: DateTime.now(),
              ),
        );

        final currentUser = context.read<AuthBloc>().state.user;
        final isOwner =
            currentUser?.id == project.clientId ||
            currentUser?.role.name == 'client';
        final isEngineer = currentUser?.role.name == 'engineer';
        final cleanCity = project.city.split('(').first.trim();

        return AppScaffold(
          title: 'تفاصيل وإدارة المشروع',
          showBackButton: true,
          backgroundColor: AppColors.primary,
          appBarBackgroundColor: AppColors.primary,
          appBarForegroundColor: Colors.black,
          systemNavigationBarColor: AppColors.background,
          safeAreaBottom: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  context.push(
                    '/chat',
                    extra: {
                      'title': 'محادثة المشروع: ${project.title}',
                      'otherName':
                          project.selectedEngineerName ?? 'المهندس المعتمد',
                      'otherRole': 'engineer',
                    },
                  );
                },
                child: const Text(
                  'محادثة المشروع',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── UPPER SECTION: Project Details Header on Teal Canvas ───
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Title & Status Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadgeOnDark(project.status),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Location & Address
                    Text(
                      '$cleanCity ${project.detailedAddress.isNotEmpty ? "• ${project.detailedAddress}" : ""}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description text
                    Text(
                      project.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Specifications Pills
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _specPillColored(
                          'المساحة: ${project.areaM2.toInt()} م²',
                        ),
                        _specPillColored(
                          'الميزانية: \$${project.approximateBudgetUsd.toInt()}',
                        ),
                        _specPillColored(
                          'النمط: ${project.preferredStyle.split('(').first.trim()}',
                        ),
                        _specPillColored(
                          'النوع: ${project.projectType.split('(').first.trim()}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Guarantee & Escrow Notice
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: AppTheme.borderRadius,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        project.isEscrowSecured
                            ? 'الضمان المالي (Escrow) مفعّل • الدفعات محمية لدى نقابة المهندسين'
                            : 'ضمان حقوق الطرفين والتحكيم الفني معتمد عبر نقابة المهندسين',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── LOWER SECTION: Distinct Bottom Container with Visible Rounded Top Corners ───
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        10,
                        12,
                        10,
                        MediaQuery.of(context).padding.bottom + 16,
                      ),
                      children: [
                        // Section: Milestones (If In-Progress or Completed)
                        if (project.status == ProjectStatus.inProgress ||
                            project.status == ProjectStatus.completed) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'مراحل الإنجاز والدفعات (Milestones)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'نسبة الإنجاز: ${project.completionPercentage}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: AppTheme.borderRadius,
                            child: LinearProgressIndicator(
                              value: project.completionPercentage / 100,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 10),

                          ...project.milestones.map(
                            (m) => _buildMilestoneCard(
                              context,
                              project,
                              m,
                              isOwner,
                              isEngineer,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Section: Received Bids (When in Bidding phase)
                        if (project.status == ProjectStatus.bidding) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'العروض الفنية والتصاميم الأولية',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: AppTheme.borderRadius,
                                ),
                                child: const Text(
                                  'عروض معتمدة',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (project.bids.isEmpty)
                            const AppEmptyState(
                              title: 'في انتظار عروض المهندسين',
                              message:
                                  'طلبك منشور في سوق المشاريع وسيصلك إشعار فور تقديم المهندسين لعروضهم ومقترحاتهم.',
                            )
                          else
                            ...project.bids.map(
                              (bid) =>
                                  _buildBidCard(context, project, bid, isOwner),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _specPillColored(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context,
    Project project,
    ProjectMilestone milestone,
    bool isOwner,
    bool isEngineer,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      borderColor: milestone.isCompleted
          ? AppColors.success.withValues(alpha: 0.4)
          : Theme.of(context).dividerColor,
      backgroundColor: milestone.isCompleted
          ? (isDark ? AppColors.darkSuccessContainer : const Color(0xFFF0FDF4))
          : Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: milestone.isCompleted
                      ? AppColors.success
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppTheme.borderRadius,
                ),
                child: Text(
                  milestone.isCompleted ? 'مكتمل' : 'قيد العمل',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: milestone.isCompleted
                        ? Colors.white
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: milestone.isCompleted
                            ? AppColors.success
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      milestone.description,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${milestone.paymentAmountUsd.toInt()}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'الوزن: ${milestone.percentageWeight}%',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isEngineer && !milestone.isCompleted) ...[
            const SizedBox(height: 8),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton.primary(
                  text: 'رفع مخرجات المرحلة واعتماد الإنجاز',
                  size: AppButtonSize.small,
                  onPressed: () {
                    context.read<ProjectsBloc>().add(
                      UpdateMilestoneRequested(
                        projectId: project.id,
                        milestoneId: milestone.id,
                        isCompleted: true,
                        proofImageUrl: 'uploaded_deliverable_proof.pdf',
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBidCard(
    BuildContext context,
    Project project,
    ProjectBid bid,
    bool isOwner,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Engineer Name, Specialty & Price Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.engineerName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${bid.engineerSpecialty} • التقييم: ${bid.engineerRating}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                  borderRadius: AppTheme.borderRadius,
                ),
                child: Text(
                  '\$${bid.proposedPriceUsd.toInt()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Proposal message text
          Text(
            bid.proposalMessage,
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4,
            ),
          ),

          // Mood Board Visual Concept Box
          if (bid.moodBoardDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkWarningContainer : const Color(0xFFFFFBEB),
                borderRadius: AppTheme.borderRadius,
                border: Border.all(color: isDark ? AppColors.warning.withValues(alpha: 0.4) : const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المقترح البصري (Mood Board Concept):',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primaryLight : const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bid.moodBoardDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF78350F),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Bottom Action Row: Duration & Accept Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppTheme.borderRadius,
                ),
                child: Text(
                  'المدة المتوقعة: ${bid.estimatedDurationDays} يوم',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
              if (isOwner)
                AppButton.primary(
                  text: 'قبول العرض وتوقيع العقد',
                  size: AppButtonSize.small,
                  onPressed: () async {
                    final confirm = await AppDialog.confirm(
                      context: context,
                      title: 'توقيع العقد الرقمي والبدء',
                      message:
                          'بقبول هذا العرض، يتم تفعيل العقد الرقمي وحماية دفعتك المالية عبر منصة عمار ونقابة المهندسين.',
                      confirmText: 'توقيع العقد وبدء التنفيذ',
                    );
                    if (confirm == true && context.mounted) {
                      context.read<ProjectsBloc>().add(
                        AcceptBidRequested(
                          projectId: project.id,
                          bidId: bid.id,
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadgeOnDark(ProjectStatus status) {
    String text;
    Color fg = AppColors.primary;
    Color bg = Colors.black;

    switch (status) {
      case ProjectStatus.bidding:
        text = 'استقبال العروض';
        fg = AppColors.primary;
        bg = Colors.black;
        break;
      case ProjectStatus.inProgress:
        text = 'قيد التنفيذ';
        fg = AppColors.primary;
        bg = Colors.black;
        break;
      case ProjectStatus.completed:
        text = 'مكتمل ومعتمد';
        fg = const Color(0xFF4ADE80);
        bg = const Color(0xFF0D2818);
        break;
      case ProjectStatus.disputed:
        text = 'نزاع لدى النقابة';
        fg = const Color(0xFFF87171);
        bg = const Color(0xFF2B0E0E);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppTheme.borderRadius),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
