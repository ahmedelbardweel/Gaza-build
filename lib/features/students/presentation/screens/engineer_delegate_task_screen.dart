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
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_bloc.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_event.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_state.dart';
import 'package:gaza_build/features/students/models/micro_task_model.dart';

class EngineerDelegateTaskScreen extends StatefulWidget {
  const EngineerDelegateTaskScreen({super.key});

  @override
  State<EngineerDelegateTaskScreen> createState() => _EngineerDelegateTaskScreenState();
}

class _EngineerDelegateTaskScreenState extends State<EngineerDelegateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController(text: '35');
  final _daysController = TextEditingController(text: '2');
  final _softwareController = TextEditingController(text: 'AutoCAD 2022+');

  String _selectedTaskType = AppConstants.microTaskTypes.first;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _daysController.dispose();
    _softwareController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = context.read<AuthBloc>().state.user;
    final task = MicroTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      engineerId: currentUser?.id ?? 'eng_curr',
      engineerName: currentUser?.fullName.isNotEmpty == true ? currentUser!.fullName : 'م. يوسف الغول',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      taskType: _selectedTaskType,
      softwareNeeded: _softwareController.text.trim(),
      rewardUsd: double.tryParse(_rewardController.text.trim()) ?? 35.0,
      deadlineDays: int.tryParse(_daysController.text.trim()) ?? 2,
      status: MicroTaskStatus.available,
      createdAt: DateTime.now(),
    );

    context.read<StudentTasksBloc>().add(CreateMicroTaskRequested(task));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentTasksBloc, StudentTasksState>(
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
          context.pop();
        }
      },
      child: AppScaffold(
        title: 'إسناد وتكليف مهمة لطالب هندسة',
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
                      title: 'تفاصيل المهمة الجزئية (Micro-Task)',
                      subtitle: 'ساعد طلاب كليات الهندسة في غزة على اكتساب دخل وتدريب عملي حقيقي تحت إشرافك',
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            label: 'عنوان المهمة *',
                            hint: 'مثال: رسم وتجهيز مسقط أفقي 2D لشقة سكنية 120 م²',
                            controller: _titleController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'عنوان المهمة مطلوب';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          AppDropdown<String>(
                            label: 'نوع المهمة الهندسية *',
                            value: _selectedTaskType,
                            items: AppConstants.microTaskTypes.map((t) {
                              return DropdownMenuItem(value: t, child: Text(t));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedTaskType = val);
                            },
                          ),
                          const SizedBox(height: 12),

                          AppTextField(
                            label: 'البرنامج الهندسي المطلوب *',
                            hint: 'AutoCAD / SketchUp / 3ds Max',
                            controller: _softwareController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'البرنامج مطلوب';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'المكافأة المالية (\$ USD) *',
                                  hint: '35',
                                  controller: _rewardController,
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'المكافأة مطلوبة';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppTextField(
                                  label: 'المهلة الزمنية للتسليم (أيام) *',
                                  hint: '2',
                                  controller: _daysController,
                                  keyboardType: TextInputType.number,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'المهلة مطلوبة';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          AppTextField(
                            label: 'شرح تفصيلي للمطلوب والمخرجات *',
                            hint: 'حدد بالتفصيل طبقات الرسم، الأبعاد، مقياس الرسم، والشروط التي تريد أن يسلمها الطالب...',
                            controller: _descriptionController,
                            maxLines: 4,
                            validator: (val) {
                              if (val == null || val.trim().length < 10) return 'يرجى كتابة تعليمات كافية للطالب';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    AppButton.primary(
                      text: 'نشر المهمة لطلاب الهندسة في المنصة',
                      size: AppButtonSize.large,
                      onPressed: _submit,
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
