import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_badge.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_dialog.dart';
import 'package:gaza_build/core/widgets/app_empty_state.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/core/widgets/app_text_field.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/syndicate/presentation/bloc/syndicate_bloc.dart';
import 'package:gaza_build/features/syndicate/presentation/bloc/syndicate_event.dart';
import 'package:gaza_build/features/syndicate/presentation/bloc/syndicate_state.dart';
import 'package:gaza_build/features/syndicate/models/syndicate_models.dart';

class SyndicateHomeScreen extends StatefulWidget {
  final BaseProfile user;

  const SyndicateHomeScreen({super.key, required this.user});

  @override
  State<SyndicateHomeScreen> createState() => _SyndicateHomeScreenState();
}

class _SyndicateHomeScreenState extends State<SyndicateHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<SyndicateBloc>().add(const LoadSyndicateDashboardRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddGuideDialog(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'مواد بديلة وتدوير');
    final summaryController = TextEditingController();
    final contentController = TextEditingController();

    AppDialog.showAppBottomSheet(
      context: context,
      title: 'نشر دليل هندسي أو كود إعمار جديد',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'عنوان الدليل أو المواصفة الهندسية *',
              hint:
                  'مثال: دليل استخدام البوزولانا والرماد المتطاير في الخرسانة',
              controller: titleController,
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: 'التصنيف / المجال *',
              hint: 'مواد بديلة / سلامة إنشائية / تشطيب اقتصادي',
              controller: categoryController,
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: 'الملخص التنفيذي *',
              hint: 'موجز سريع حول أهمية الكود والمستفيدين منه...',
              controller: summaryController,
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            AppTextField(
              label: 'المحتوى والاشتراطات الفنية المعتمدة *',
              hint: 'المعايير والنسب ونقاط الفحص الفني...',
              controller: contentController,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            AppButton.primary(
              text: 'اعتماد ونشر الدليل للمجتمع الهندسي',
              size: AppButtonSize.large,
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                final guide = ReconstructionGuide(
                  id: '',
                  title: titleController.text.trim(),
                  category: categoryController.text.trim(),
                  summary: summaryController.text.trim(),
                  fullContent: contentController.text.trim(),
                  publishedDate: DateTime.now(),
                );

                context.read<SyndicateBloc>().add(AddGuideRequested(guide));
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  void _showArbitrationRulingDialog(
    BuildContext context,
    ArbitrationCase dispute,
  ) {
    final rulingController = TextEditingController();

    AppDialog.showAppBottomSheet(
      context: context,
      title: 'إصدار قرار لجنة التحكيم الهندسي',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'المشروع: ${dispute.projectTitle}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'الطرفان: ${dispute.clientName} (مالك) • ${dispute.engineerName} (مهندس)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'سبب النزاع: ${dispute.disputeReason}',
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
          const SizedBox(height: 12),

          AppTextField(
            label: 'نص قرار اللجنة والحل الفني المعتمد *',
            hint: 'اكتب التوجيه الفني الملزم ومصير الدفعة المالية المحتجزة...',
            controller: rulingController,
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          AppButton.primary(
            text: 'إصدار وتوثيق قرار التحكيم الملزم',
            size: AppButtonSize.large,
            onPressed: () {
              if (rulingController.text.trim().isEmpty) return;

              context.read<SyndicateBloc>().add(
                IssueRulingRequested(
                  caseId: dispute.id,
                  ruling: rulingController.text.trim(),
                ),
              );
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SyndicateBloc, SyndicateState>(
      listener: (context, state) {
        if (state.status == SyndicateStatus.actionSuccess &&
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
        return AppScaffold(
          title: 'لوحة القيادة والرقابة - نقابة المهندسين',
          userProfile: widget.user,
          showUserRoleHeader: true,
          bottomAppBar: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            dividerColor: Colors.transparent,
            dividerHeight: 0.0,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                text: 'طلبات الاعتماد (${state.pendingVerifications.length})',
              ),
              Tab(text: 'أدلة الإعمار (${state.guides.length})'),
              Tab(text: 'لجنة التحكيم (${state.arbitrationCases.length})'),
              const Tab(text: 'مؤشرات وإحصائيات القطاع'),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Pending Verifications
              _buildVerificationsTab(state),

              // Tab 2: Reconstruction Guides & Codes
              _buildGuidesTab(state),

              // Tab 3: Arbitration Tribunal
              _buildArbitrationTab(state),

              // Tab 4: Sector Statistics & KPIs
              _buildStatsTab(state),
            ],
          ),
        );
      },
    );
  }

  // ─── Tab 1: Verifications ────────────────────────────────────────────────
  Widget _buildVerificationsTab(SyndicateState state) {
    if (state.pendingVerifications.isEmpty) {
      return const AppEmptyState(
        title: 'لا توجد طلبات اعتماد معلقة',
        message:
            'تم تدقيق واعتماد كافة طلبات المهندسين وطلاب الهندسة المسجلين في المنصة.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: state.pendingVerifications.length,
      itemBuilder: (context, index) {
        final applicant = state.pendingVerifications[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          title: applicant.fullName.isNotEmpty
              ? applicant.fullName
              : applicant.email,
          subtitle: 'المحافظة: ${applicant.city} • هاتف: ${applicant.phone}',
          trailing: AppBadge.role(applicant.role.name),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton.danger(
                text: 'رفض مع ملاحظة',
                size: AppButtonSize.small,
                onPressed: () {
                  context.read<SyndicateBloc>().add(
                    UpdateVerificationRequested(
                      userId: applicant.id,
                      status: VerificationStatus.rejected,
                      rejectionReason:
                          'يرجى إعادة رفع صورة واضحة لشهادة مزاولة المهنة.',
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              AppButton.primary(
                text: 'اعتماد وتوثيق',
                size: AppButtonSize.small,
                onPressed: () {
                  context.read<SyndicateBloc>().add(
                    UpdateVerificationRequested(
                      userId: applicant.id,
                      status: VerificationStatus.approved,
                    ),
                  );
                },
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (applicant.bio.isNotEmpty) ...[
                Text(
                  applicant.bio,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppTheme.borderRadius,
                ),
                child: Text(
                  'مستندات التخرج وإثبات القيد مرفقة وتم تدقيق التوقيع الرقمي',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Tab 2: Guides & Codes ───────────────────────────────────────────────
  Widget _buildGuidesTab(SyndicateState state) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: AppButton.secondary(
        text: 'نشر دليل جديد +',
        size: AppButtonSize.medium,
        onPressed: () => _showAddGuideDialog(context),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: state.guides.length,
        itemBuilder: (context, index) {
          final guide = state.guides[index];
          return AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            title: guide.title,
            subtitle: '${guide.category} • ${guide.author}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.summary,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
                if (guide.approvedMaterials.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: guide.approvedMaterials.map((m) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E1065) : const Color(0xFFF3E8FF),
                          borderRadius: AppTheme.borderRadius,
                          border: Border.all(color: isDark ? const Color(0xFF581C87) : const Color(0xFFE9D5FF)),
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF6B21A8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Tab 3: Arbitration Panel ────────────────────────────────────────────
  Widget _buildArbitrationTab(SyndicateState state) {
    if (state.arbitrationCases.isEmpty) {
      return const AppEmptyState(
        title: 'سجل التحكيم خالٍ من النزاعات',
        message:
            'كافة المشاريع تسير وفق العقود الرقمية المعتمدة ولم يتم رفع أي منازعات.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: state.arbitrationCases.length,
      itemBuilder: (context, index) {
        final dispute = state.arbitrationCases[index];
        final isResolved = dispute.status == 'resolved';
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AppCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          title: dispute.projectTitle,
          subtitle:
              'المدعي: ${dispute.clientName} | المدعى عليه: ${dispute.engineerName}',
          trailing: AppBadge.status(isResolved ? 'completed' : 'disputed'),
          footer: !isResolved
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton.primary(
                      text: 'دراسة النزاع وإصدار القرار الملزم',
                      size: AppButtonSize.small,
                      onPressed: () =>
                          _showArbitrationRulingDialog(context, dispute),
                    ),
                  ],
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سبب النزاع: ${dispute.disputeReason}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.error,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'المطلب: ${dispute.requestedResolution}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              if (dispute.syndicateRuling != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSuccessContainer : AppColors.successContainer,
                    borderRadius: AppTheme.borderRadius,
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'قرار لجنة التحكيم المعتمد:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dispute.syndicateRuling!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ─── Tab 4: Statistics & KPIs ────────────────────────────────────────────
  Widget _buildStatsTab(SyndicateState state) {
    final stats = state.statistics;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF270E4A) : const Color(0xFF581C87),
              borderRadius: AppTheme.borderRadius,
              border: Border.all(color: isDark ? const Color(0xFF6B21A8) : Colors.transparent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرصد إعادة الإعمار والتصميم الرقمي في قطاع غزة',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFE9D5FF) : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'بيانات فورية توثق مساهمة المنظومة الهندسية في دعم صمود المواطنين وإعادة تأهيل المباني المتضررة.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFFD8B4FE) : Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statMetricCard(
                  context: context,
                  label: 'مهندسون معتمدون',
                  value: '${stats.totalVerifiedEngineers}',
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statMetricCard(
                  context: context,
                  label: 'طلاب تم تدريبهم',
                  value: '${stats.totalActiveStudents}',
                  color: AppColors.studentRole,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _statMetricCard(
                  context: context,
                  label: 'مشاريع إعمار نشطة',
                  value: '${stats.totalReconstructionProjects}',
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.clientRole,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statMetricCard(
                  context: context,
                  label: 'المساحة المعاد تأهيلها',
                  value: '${(stats.totalReconstructedAreaM2 / 1000).toStringAsFixed(1)}K م²',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _statMetricCard(
                  context: context,
                  label: 'حجم العقود المضمونة',
                  value:
                      '\$${(stats.estimatedContractVolumeUsd / 1000).toStringAsFixed(1)}K',
                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statMetricCard(
                  context: context,
                  label: 'دخل مكتسب للطلاب',
                  value:
                      '\$${(stats.studentEarnedIncomeUsd / 1000).toStringAsFixed(1)}K',
                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statMetricCard({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
