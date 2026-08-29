import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_badge.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_empty_state.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_bloc.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_event.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_state.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_event.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_state.dart';
import 'package:gaza_build/features/projects/models/project_model.dart';

class EngineerHomeScreen extends StatefulWidget {
  final BaseProfile user;

  const EngineerHomeScreen({super.key, required this.user});

  @override
  State<EngineerHomeScreen> createState() => _EngineerHomeScreenState();
}

class _EngineerHomeScreenState extends State<EngineerHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
    context.read<ProjectsBloc>().add(const LoadProjectsRequested());
    context.read<StudentTasksBloc>().add(const LoadStudentTasksRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUser = authState.user ?? widget.user;

        return AppScaffold(
          title: 'لوحة تحكم مهندس الديكور والمعماري',
          userProfile: currentUser,
          showUserRoleHeader: true,
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<AuthBloc>().add(const AuthCheckRequested());
              context.read<ProjectsBloc>().add(const LoadProjectsRequested());
              context.read<StudentTasksBloc>().add(const LoadStudentTasksRequested());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Verification status banner dynamically driven by currentUser
                  _buildVerificationBanner(currentUser),
                  const SizedBox(height: 12),

                  // Quick Actions Grid
                  Row(
                    children: [
                      Expanded(
                        child: _actionCard(
                          title: 'سوق المشاريع في غزة',
                          subtitle: 'تصفح وتقديم عروض',
                          color: AppColors.primary,
                          onTap: () => context.push('/projects/marketplace'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionCard(
                          title: 'إسناد مهمة لطالب',
                          subtitle: 'رسم 2D / كتلة 3D',
                          color: AppColors.studentRole,
                          onTap: () => context.push('/engineer/delegate-task'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section: My Active Contracted Projects
                  BlocBuilder<ProjectsBloc, ProjectsState>(
                    builder: (context, state) {
                      final activeProjects = state.projects
                          .where((p) => p.status == ProjectStatus.inProgress || p.selectedEngineerId == currentUser.id)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'مشاريعي قيد التنفيذ (${activeProjects.length})',
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => context.push('/projects/marketplace'),
                                child: const Text('استعراض السوق'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          if (activeProjects.isEmpty)
                            AppEmptyState(
                              title: 'لا توجد مشاريع متعاقد عليها حالياً',
                              message: 'تصفح سوق المشاريع في غزة وقدم عروضك الفنية للملاك.',
                              actionText: 'تصفح سوق المشاريع',
                              onAction: () => context.push('/projects/marketplace'),
                            )
                          else
                            ...activeProjects.map((p) => _buildActiveProjectItem(context, p)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Section: My Delegated Micro Tasks to Students
                  BlocBuilder<StudentTasksBloc, StudentTasksState>(
                    builder: (context, state) {
                      final myTasks = state.tasks
                          .where((t) => t.engineerId == currentUser.id)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'مهام فريق الطلاب المساعدين (${myTasks.length})',
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => context.push('/engineer/delegate-task'),
                                child: const Text(
                                  'إسناد مهمة +',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.studentRole),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          if (myTasks.isEmpty)
                            AppEmptyState(
                              title: 'لم تسند أي مهام للطلاب حتى الآن',
                              message: 'يمكنك الاستعانة بطلاب الهندسة المتميزين لإنجاز مخططات الأوتوكاد والرفع ثلاثي الأبعاد.',
                              actionText: 'إسناد مهمة جديدة للطلاب',
                              onAction: () => context.push('/engineer/delegate-task'),
                            )
                          else
                            ...myTasks.map((t) => _buildDelegatedTaskItem(context, t)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationBanner(BaseProfile user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user.verificationStatus == VerificationStatus.approved) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSuccessContainer : const Color(0xFFF0FDF4),
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: isDark ? AppColors.success.withValues(alpha: 0.4) : const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حساب مهندس معتمد وموثق نقابياً',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'يحق لك تقديم عروض أسعار هندسية معتمدة وتصدير مخططات للمحافظات.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (user.verificationStatus == VerificationStatus.rejected) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkErrorContainer : const Color(0xFFFEF2F2),
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: isDark ? AppColors.error.withValues(alpha: 0.4) : const Color(0xFFFECACA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم رفض الاعتماد من نقابة المهندسين',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF87171) : AppColors.error,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user.rejectionReason ?? 'يرجى مراجعة وتحديث أوراقك وإعادة رفعها للتدقيق.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? const Color(0xFFFCA5A5) : AppColors.error,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    }

    // Pending
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkWarningContainer : const Color(0xFFFFFBEB),
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: isDark ? AppColors.warning.withValues(alpha: 0.4) : const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طلب الاعتماد النقابي قيد التدقيق',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.primaryLight : const Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'تقوم لجنة التحكيم بالنقابة بالتحقق من رقم عضويتك وشهادتك لاعتماد شارة التوثيق.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF92400E),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.borderRadius,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: AppTheme.borderRadius,
              ),
              child: Text(
                title,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjectItem(BuildContext context, Project project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/projects/details/${project.id}', extra: project),
      title: project.title,
      subtitle: 'المالك: ${project.clientName} • \$${project.agreedPriceUsd?.toInt() ?? project.approximateBudgetUsd.toInt()}',
      trailing: AppBadge.status(project.status.name),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'إدارة المراحل ورفع المخرجات',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          AppButton.outline(
            text: 'تحديث المرحلة',
            size: AppButtonSize.small,
            onPressed: () => context.push('/projects/details/${project.id}', extra: project),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مراحل الإنجاز (${project.milestones.where((m) => m.isCompleted).length}/${project.milestones.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '${project.completionPercentage}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppTheme.borderRadius,
            child: LinearProgressIndicator(
              value: project.completionPercentage / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelegatedTaskItem(BuildContext context, dynamic task) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      title: task.title,
      subtitle: task.assignedStudentName != null
          ? 'المكلف: ${task.assignedStudentName} • \$${task.rewardUsd.toInt()}'
          : 'بانتظار طالب متقدم • \$${task.rewardUsd.toInt()}',
      trailing: AppBadge.status(task.status.name),
    );
  }
}
