import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_badge.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_dialog.dart';
import 'package:gaza_build/core/widgets/app_empty_state.dart';
import 'package:gaza_build/core/widgets/app_loader.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/core/widgets/app_text_field.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_bloc.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_event.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_state.dart';
import 'package:gaza_build/features/students/models/micro_task_model.dart';

class StudentHomeScreen extends StatefulWidget {
  final BaseProfile user;

  const StudentHomeScreen({super.key, required this.user});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
    context.read<StudentTasksBloc>().add(const LoadStudentTasksRequested());
  }

  void _showSubmitDeliverableDialog(BuildContext context, MicroTask task) {
    final noteController = TextEditingController();
    bool filePicked = false;

    AppDialog.showCustom(
      context: context,
      title: 'تسليم مخرجات المهمة',
      content: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المهمة: ${task.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            AppTextField(
              label: 'ملاحظات التسليم والتوضيحات للمهندس',
              hint: 'تم رسم المسقط بالكامل ومطابقة أبعاد الجدران...',
              controller: noteController,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setDialogState(() => filePicked = true);
              },
              borderRadius: AppTheme.borderRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppTheme.borderRadius,
                  border: Border.all(
                    color: filePicked ? AppColors.success : Theme.of(context).dividerColor,
                    width: filePicked ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      filePicked ? Icons.check_circle : Icons.upload_file,
                      color: filePicked ? AppColors.success : AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      filePicked ? 'تم إرفاق ملف المخطط (student_work.dwg)' : 'اضغط لاختيار ملف DWG / PDF / ZIP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: filePicked ? FontWeight.bold : FontWeight.normal,
                        color: filePicked ? AppColors.success : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              text: 'تأكيد تسليم المخرجات',
              size: AppButtonSize.medium,
              isFullWidth: true,
              onPressed: () {
                if (noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى كتابة ملاحظات التسليم أولاً')),
                  );
                  return;
                }

                context.read<StudentTasksBloc>().add(
                      SubmitTaskDeliverableRequested(
                        taskId: task.id,
                        deliverableNote: noteController.text.trim(),
                        fileUrl: 'student_work.dwg',
                      ),
                    );
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUser = authState.user ?? widget.user;

        return AppScaffold(
          title: 'لوحة تحكم طالب الهندسة والمساعد',
          userProfile: currentUser,
          showUserRoleHeader: true,
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<AuthBloc>().add(const AuthCheckRequested());
              context.read<StudentTasksBloc>().add(const LoadStudentTasksRequested());
            },
            child: BlocConsumer<StudentTasksBloc, StudentTasksState>(
              listener: (context, state) {
                if (state.status == StudentTasksStatus.actionSuccess && state.successMessage != null) {
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
                if (state.status == StudentTasksStatus.loading && state.tasks.isEmpty) {
                  return const Center(
                    child: AppLoader(
                      message: 'جاري تحميل وتحديث مهام الطلاب والمساعدين...',
                    ),
                  );
                }

                final availableTasks = state.tasks.where((t) => t.status == MicroTaskStatus.available).toList();
                final myTasks = state.tasks
                    .where((t) => t.assignedStudentId == currentUser.id || t.assignedStudentId == 'student_curr')
                    .toList();

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Verification / Intern Banner
                      _buildVerificationBanner(currentUser),
                      const SizedBox(height: 14),

                      // Section: My Active Tasks
                      if (myTasks.isNotEmpty) ...[
                        Text(
                          'مهامي الجارية (${myTasks.length})',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...myTasks.map((t) => _buildMyTaskCard(context, t)),
                        const SizedBox(height: 14),
                      ],

                      // Section: Available Tasks from Architects
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'مهام متاحة من المهندسين (${availableTasks.length})',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'كسب دخل وخبرة عملية',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      if (availableTasks.isEmpty)
                        const AppEmptyState(
                          title: 'لا توجد مهام جديدة حالياً',
                          message: 'ينشر المهندسون مهام الرسم والمخططات بشكل مستمر. سيصلك إشعار فور توفر مهمة تناسب مهاراتك.',
                        )
                      else
                        ...availableTasks.map((task) => _buildAvailableTaskCard(context, task)),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationBanner(BaseProfile user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApproved = user.verificationStatus == VerificationStatus.approved;
    final isRejected = user.verificationStatus == VerificationStatus.rejected;

    if (isApproved) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3B1A06) : const Color(0xFFC2410C),
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: isDark ? const Color(0xFFEA580C) : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طالب هندسة معتمد وموثق • باحث عن فرص عمل وتدريب',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFFDBA74) : Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'مهام أوتوكاد و 3D بإشراف وتوجيه المهندسين المعتمدين',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? const Color(0xFFFED7AA) : Colors.white70,
              ),
            ),
          ],
        ),
      );
    } else if (isRejected) {
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
              'طلب توثيق القيد بحاجة لتعديل من النقابة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF87171) : AppColors.error,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user.rejectionReason ?? 'يرجى إعادة رفع إثبات قيد جامعي واضح.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? const Color(0xFFFCA5A5) : AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

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
            'طلب التحقق من القيد الجامعي قيد التدقيق بالنقابة',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.primaryLight : const Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'يتم التحقق من بطاقتك الجامعية لمنحك شارة الطالب المعتمد لتلقي المهام.',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTaskCard(BuildContext context, MicroTask task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      title: task.title,
      subtitle: 'المشرف: ${task.engineerName} • البرنامج: ${task.softwareNeeded}',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A1A05) : const Color(0xFFFFEDD5),
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: isDark ? const Color(0xFF9A3412) : Colors.transparent),
        ),
        child: Text(
          '\$${task.rewardUsd.toInt()}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.description,
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'المهلة: ${task.deadlineDays} أيام',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              AppButton.primary(
                text: 'استلام المهمة والبدء',
                size: AppButtonSize.small,
                onPressed: () {
                  context.read<StudentTasksBloc>().add(
                        ApplyForTaskRequested(
                          taskId: task.id,
                          studentId: widget.user.id,
                          studentName: widget.user.fullName.isNotEmpty ? widget.user.fullName : 'طالب متدرب',
                        ),
                      );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyTaskCard(BuildContext context, MicroTask task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnderReview = task.status == MicroTaskStatus.underReview;
    final isCompleted = task.status == MicroTaskStatus.completed;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      title: task.title,
      subtitle: 'المشرف: ${task.engineerName} • المكافأة: \$${task.rewardUsd.toInt()}',
      trailing: AppBadge.status(task.status.name),
      footer: !isCompleted
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUnderReview ? 'بانتظار مراجعة واعتماد المهندس' : 'المهمة قيد التنفيذ',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isUnderReview ? AppColors.secondaryLight : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isUnderReview)
                  AppButton.primary(
                    text: 'تسليم المخرجات',
                    size: AppButtonSize.small,
                    onPressed: () => _showSubmitDeliverableDialog(context, task),
                  ),
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.description,
            style: TextStyle(
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (task.mentorFeedback != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSuccessContainer : AppColors.successContainer,
                borderRadius: AppTheme.borderRadius,
              ),
              child: Text(
                'ملاحظات المهندس: ${task.mentorFeedback}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.success),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
