import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_badge.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_empty_state.dart';
import 'package:gaza_build/core/widgets/app_loader.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_bloc.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_event.dart';
import 'package:gaza_build/features/projects/presentation/bloc/projects_state.dart';
import 'package:gaza_build/features/projects/models/project_model.dart';

class ClientHomeScreen extends StatefulWidget {
  final BaseProfile user;

  const ClientHomeScreen({super.key, required this.user});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(const LoadProjectsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: 'لوحة تحكم صاحب المشروع',
      userProfile: widget.user,
      showUserRoleHeader: true,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProjectsBloc>().add(const LoadProjectsRequested());
        },
        child: BlocBuilder<ProjectsBloc, ProjectsState>(
          builder: (context, state) {
            if (state.status == ProjectsStatus.loading && state.projects.isEmpty) {
              return const Center(
                child: AppLoader(
                  message: 'جاري تحديث واسترجاع مشاريعك من السحابة...',
                ),
              );
            }

            final allClientProjects = state.projects
                .where((p) => p.clientId == widget.user.id)
                .toList();

            final biddingCount = allClientProjects
                .where((p) => p.status == ProjectStatus.bidding)
                .length;
            final inProgressCount = allClientProjects
                .where((p) => p.status == ProjectStatus.inProgress)
                .length;
            final completedCount = allClientProjects
                .where((p) => p.status == ProjectStatus.completed)
                .length;

            final filteredProjects = allClientProjects.where((p) {
              if (_selectedFilter == 'bidding') {
                return p.status == ProjectStatus.bidding;
              }
              if (_selectedFilter == 'in_progress') {
                return p.status == ProjectStatus.inProgress;
              }
              if (_selectedFilter == 'completed') {
                return p.status == ProjectStatus.completed;
              }
              return true;
            }).toList();

            final totalBids = allClientProjects.fold<int>(
              0,
              (sum, p) => sum + p.bids.length,
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Quick Stats Summary
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: AppTheme.borderRadius,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSummaryMetric(
                            label: 'مشاريعي',
                            value: '${allClientProjects.length}',
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Theme.of(context).dividerColor,
                        ),
                        Expanded(
                          child: _buildSummaryMetric(
                            label: 'عروض مستلمة',
                            value: '$totalBids',
                            color: isDark ? AppColors.primaryLight : AppColors.secondaryDark,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Theme.of(context).dividerColor,
                        ),
                        Expanded(
                          child: _buildSummaryMetric(
                            label: 'قيد التنفيذ',
                            value: '$inProgressCount',
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 2. Dual Interactive Action Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card 1: Create Project
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push('/projects/create'),
                          borderRadius: AppTheme.borderRadius,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: AppTheme.borderRadius,
                              border: Border.all(
                                color: isDark
                                    ? Theme.of(context).dividerColor
                                    : AppColors.primary.withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkPrimaryContainer
                                        : AppColors.primaryContainer,
                                    borderRadius: AppTheme.borderRadius,
                                  ),
                                  child: Text(
                                    'عروض وتصاميم',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'طرح مشروع جديد',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'إعادة إعمار، ترميم، تشطيب شقق وديكورات',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkPrimaryContainer
                                        : AppColors.primaryContainer,
                                    borderRadius: AppTheme.borderRadius,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'طرح الطلب الآن',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Card 2: Quick Consultation
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push('/quick-consult'),
                          borderRadius: AppTheme.borderRadius,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: AppTheme.borderRadius,
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkPrimaryContainer
                                        : AppColors.primaryContainer,
                                    borderRadius: AppTheme.borderRadius,
                                  ),
                                  child: Text(
                                    'استشارة فورية',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'استشارة مهندس',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'رأي فوري لمواد البناء البديلة والألوان والأثاث',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                                        : AppColors.primaryContainer,
                                    borderRadius: AppTheme.borderRadius,
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'محادثة مباشرة',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 3. Projects Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterTab(
                          'الكل (${allClientProjects.length})',
                          'all',
                        ),
                        const SizedBox(width: 6),
                        _buildFilterTab(
                          'تلقي العروض ($biddingCount)',
                          'bidding',
                        ),
                        const SizedBox(width: 6),
                        _buildFilterTab(
                          'قيد التنفيذ ($inProgressCount)',
                          'in_progress',
                        ),
                        const SizedBox(width: 6),
                        _buildFilterTab(
                          'المكتملة ($completedCount)',
                          'completed',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 4. Projects List
                  if (filteredProjects.isEmpty)
                    AppEmptyState(
                      title: 'لا توجد مشاريع في هذا القسم',
                      message:
                          'ابدأ بطرح أول مشروع لإعادة إعمار منزلك أو تشطيب شقتك واستقبل العروض.',
                      actionText: 'طرح مشروع جديد',
                      onAction: () => context.push('/projects/create'),
                    )
                  else
                    ...filteredProjects.map(
                      (project) => _buildProjectCard(context, project),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String title, String filterKey) {
    final isSelected = _selectedFilter == filterKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterKey),
      borderRadius: AppTheme.borderRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: AppTheme.borderRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.black
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final cityName = project.city.split('(').first.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      onTap: () =>
          context.push('/projects/details/${project.id}', extra: project),
      title: project.title,
      subtitle: '$cityName • المساحة: ${project.areaM2.toInt()} م²',
      trailing: AppBadge.status(project.status.name),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),

          // Metadata pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _infoPill('الميزانية: \$${project.approximateBudgetUsd.toInt()}'),
              _infoPill(project.projectType.split(' ').first),
              if (project.status == ProjectStatus.bidding)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                    borderRadius: AppTheme.borderRadius,
                  ),
                  child: Text(
                    '${project.bids.length} عروض مستلمة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),

          // Progress section if in progress
          if (project.status == ProjectStatus.inProgress) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: AppTheme.borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المهندس: ${project.selectedEngineerName ?? "معتمد"}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'نسبة الإنجاز: ${project.completionPercentage}%',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: AppTheme.borderRadius,
                    child: LinearProgressIndicator(
                      value: project.completionPercentage / 100,
                      backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Contextual Action Button
          if (project.status == ProjectStatus.bidding)
            AppButton.primary(
              text: 'مراجعة العروض الهندسية (${project.bids.length})',
              size: AppButtonSize.small,
              isFullWidth: true,
              onPressed: () => context.push(
                '/projects/details/${project.id}',
                extra: project,
              ),
            )
          else if (project.status == ProjectStatus.inProgress)
            AppButton.outline(
              text: 'متابعة مراحل التنفيذ والضمان المالي',
              size: AppButtonSize.small,
              isFullWidth: true,
              onPressed: () => context.push(
                '/projects/details/${project.id}',
                extra: project,
              ),
            )
          else
            AppButton.tonal(
              text: 'عرض تفاصيل المشروع والمخططات',
              size: AppButtonSize.small,
              isFullWidth: true,
              onPressed: () => context.push(
                '/projects/details/${project.id}',
                extra: project,
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoPill(String text) {
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
