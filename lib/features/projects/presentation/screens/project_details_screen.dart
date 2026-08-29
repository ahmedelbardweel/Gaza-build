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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.primaryLight : Colors.black,
                  side: BorderSide(
                    color: isDark ? AppColors.primaryLight : Colors.black,
                    width: 1,
                  ),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── UPPER SECTION: Project Details Header Card ───
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Theme.of(context).colorScheme.surface
                        : AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppTheme.borderRadius,
                    border: Border.all(
                      color: isDark
                          ? Theme.of(context).dividerColor
                          : AppColors.primary.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(context, project.status),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Location & Address
                      Text(
                        '$cleanCity ${project.detailedAddress.isNotEmpty ? "• ${project.detailedAddress}" : ""}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description text
                      Text(
                        project.description,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Specifications Pills
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _specPill(context, 'المساحة: ${project.areaM2.toInt()} م²'),
                          _specPill(context, 'الميزانية: \$${project.approximateBudgetUsd.toInt()}'),
                          _specPill(context, 'النمط: ${project.preferredStyle.split('(').first.trim()}'),
                          _specPill(context, 'النوع: ${project.projectType.split('(').first.trim()}'),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Guarantee & Escrow Notice
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkPrimaryContainer
                              : AppColors.primaryContainer,
                          borderRadius: AppTheme.borderRadius,
                          border: Border.all(
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 16,
                              color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                project.isEscrowSecured
                                    ? 'الضمان المالي (Escrow) مفعّل • الدفعات محمية لدى نقابة المهندسين'
                                    : 'ضمان حقوق الطرفين والتحكيم الفني معتمد عبر نقابة المهندسين',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.primaryLight : const Color(0xFF92400E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Section: Milestones (If In-Progress or Completed)
                if (project.status == ProjectStatus.inProgress ||
                    project.status == ProjectStatus.completed) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مراحل الإنجاز والدفعات (Milestones)',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'نسبة الإنجاز: ${project.completionPercentage}%',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppTheme.borderRadius,
                    child: LinearProgressIndicator(
                      value: project.completionPercentage / 100,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  const SizedBox(height: 14),
                ],

                // Section: Received Bids (When in Bidding phase)
                if (project.status == ProjectStatus.bidding) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'العروض الفنية والتصاميم الأولية (${project.bids.length})',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                          borderRadius: AppTheme.borderRadius,
                        ),
                        child: Text(
                          'عروض معتمدة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
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
        );
      },
    );
  }

  Widget _specPill(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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

  Widget _buildStatusBadge(BuildContext context, ProjectStatus status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String text;
    Color fg;
    Color bg;

    switch (status) {
      case ProjectStatus.bidding:
        text = 'استقبال العروض';
        fg = isDark ? AppColors.primaryLight : AppColors.primaryDark;
        bg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer;
        break;
      case ProjectStatus.inProgress:
        text = 'قيد التنفيذ';
        fg = isDark ? AppColors.primaryLight : AppColors.primaryDark;
        bg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer;
        break;
      case ProjectStatus.completed:
        text = 'مكتمل ومعتمد';
        fg = const Color(0xFF4ADE80);
        bg = isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7);
        break;
      case ProjectStatus.disputed:
        text = 'نزاع لدى النقابة';
        fg = const Color(0xFFF87171);
        bg = isDark ? const Color(0xFF2B0E0E) : const Color(0xFFFEE2E2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
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
