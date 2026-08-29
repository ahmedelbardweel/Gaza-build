import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/core/constants/app_constants.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_badge.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_card.dart';
import 'package:gaza_build/core/widgets/app_chip_selector.dart';
import 'package:gaza_build/core/widgets/app_dropdown.dart';
import 'package:gaza_build/core/widgets/app_text_field.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_build/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaza_build/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:gaza_build/features/profile/presentation/bloc/profile_event.dart';
import 'package:gaza_build/features/profile/presentation/bloc/profile_state.dart';
import 'package:gaza_build/features/profile/models/profile_models.dart';

class CompleteProfileScreen extends StatefulWidget {
  final BaseProfile user;

  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common Base Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late String _selectedCity;

  // 1. Engineer Specific Controllers
  final _officeNameController = TextEditingController();
  final _syndicateNumberController = TextEditingController(text: 'ENG-GZ-2024-884');
  final _experienceYearsController = TextEditingController(text: '4');
  final _portfolioDescController = TextEditingController();
  List<String> _selectedEngineerSpecialties = [];
  List<String> _selectedEngineerSoftware = [];
  bool _degreeUploaded = false;

  // 2. Client Specific Controllers
  final _propertyAddressController = TextEditingController();
  final _propertyAreaController = TextEditingController(text: '120');
  final _propertyNotesController = TextEditingController();
  String _selectedPropertyType = 'شقة سكنية';
  List<String> _selectedClientNeeds = [];

  // 3. Student Specific Controllers
  late String _selectedUniversity;
  late String _selectedDepartment;
  int _selectedYearOfStudy = 3;
  String _availableHoursPerWeek = '20 ساعة أسبوعياً';
  List<String> _selectedStudentSkills = [];
  bool _studentIdUploaded = false;
  bool _availableForInternship = true;

  // 4. Syndicate Specific Controllers
  final _officialTitleController = TextEditingController(text: 'مقرر لجنة التحكيم والاعتماد الهندسي');
  final _departmentController = TextEditingController(text: 'دائرة التخطيط والمواصفات ولجنة الطوارئ');
  final _resolutionNumberController = TextEditingController(text: 'RES-GZ-2024/119');
  String _selectedSyndicateBranch = 'مقر النقابة الرئيسي - مدينة غزة';
  final bool _authDocUploaded = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _bioController = TextEditingController(text: widget.user.bio);

    _selectedCity = AppConstants.gazaCities.firstWhere(
      (c) => c == widget.user.city || c.contains(widget.user.city) || widget.user.city.contains(c),
      orElse: () => AppConstants.gazaCities.first,
    );

    _selectedUniversity = AppConstants.gazaUniversities.first;
    _selectedDepartment = AppConstants.studentDepartments.first;

    // Role-specific default values
    _selectedEngineerSpecialties = [AppConstants.engineerSpecialties.first];
    _selectedEngineerSoftware = ['AutoCAD', '3ds Max', 'SketchUp'];
    _selectedClientNeeds = [AppConstants.clientProjectTypes.first];
    _selectedStudentSkills = [AppConstants.studentSkills[0], AppConstants.studentSkills[1]];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();

    _officeNameController.dispose();
    _syndicateNumberController.dispose();
    _experienceYearsController.dispose();
    _portfolioDescController.dispose();

    _propertyAddressController.dispose();
    _propertyAreaController.dispose();
    _propertyNotesController.dispose();

    _officialTitleController.dispose();
    _departmentController.dispose();
    _resolutionNumberController.dispose();
    super.dispose();
  }

  void _submitProfile() {
    if (!_formKey.currentState!.validate()) return;

    final updatedBase = widget.user.copyWith(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _selectedCity,
      bio: _bioController.text.trim(),
      role: widget.user.role,
      isProfileComplete: true,
      verificationStatus: widget.user.role == UserRole.client
          ? VerificationStatus.approved
          : VerificationStatus.pending,
    );

    EngineerProfile? engineerProfile;
    ClientProfile? clientProfile;
    StudentProfile? studentProfile;
    SyndicateProfile? syndicateProfile;

    switch (widget.user.role) {
      case UserRole.engineer:
        engineerProfile = EngineerProfile(
          userId: widget.user.id,
          syndicateMembershipNumber: _syndicateNumberController.text.trim().isNotEmpty
              ? _syndicateNumberController.text.trim()
              : 'ENG-GZ-2024-884',
          yearsOfExperience: int.tryParse(_experienceYearsController.text.trim()) ?? 3,
          specialties: _selectedEngineerSpecialties,
          portfolioDescription: _portfolioDescController.text.trim(),
          universityDegreeUrl: _degreeUploaded ? 'uploaded_degree_verified.pdf' : 'degree_placeholder.pdf',
        );
        break;

      case UserRole.client:
        clientProfile = ClientProfile(
          userId: widget.user.id,
          address: _propertyAddressController.text.trim(),
          preferredProjectTypes: _selectedClientNeeds,
          propertyConditionNote: _propertyNotesController.text.trim(),
        );
        break;

      case UserRole.student:
        studentProfile = StudentProfile(
          userId: widget.user.id,
          university: _selectedUniversity,
          department: _selectedDepartment,
          yearOfStudy: _selectedYearOfStudy,
          skills: _selectedStudentSkills,
          availableForInternship: _availableForInternship,
          enrollmentProofUrl: _studentIdUploaded ? 'uploaded_student_id.pdf' : 'student_card.jpg',
        );
        break;

      case UserRole.syndicate:
        syndicateProfile = SyndicateProfile(
          userId: widget.user.id,
          officialTitle: _officialTitleController.text.trim(),
          department: _departmentController.text.trim(),
          authorizationDocumentUrl: _authDocUploaded ? 'syndicate_auth.pdf' : '',
        );
        break;
    }

    context.read<ProfileBloc>().add(
          CompleteProfileSubmitted(
            baseProfile: updatedBase,
            engineerProfile: engineerProfile,
            clientProfile: clientProfile,
            studentProfile: studentProfile,
            syndicateProfile: syndicateProfile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إكمال ملف ${widget.user.role.displayName}'),
        centerTitle: false,
        titleSpacing: 10,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success && state.updatedProfile != null) {
            context.read<AuthBloc>().add(
                  AuthProfileUpdatedLocally(state.updatedProfile!),
                );
          } else if (state.status == ProfileStatus.error && state.errorMessage != null) {
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
        builder: (context, state) {
          final isLoading = state.status == ProfileStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Role Banner
                        _buildRoleHeaderBanner(),
                        const SizedBox(height: 14),

                        // Form specifically tailored for the user's Supabase role
                        if (widget.user.role == UserRole.engineer) ...[
                          _buildEngineerForm(),
                        ] else if (widget.user.role == UserRole.client) ...[
                          _buildClientForm(),
                        ] else if (widget.user.role == UserRole.student) ...[
                          _buildStudentForm(),
                        ] else if (widget.user.role == UserRole.syndicate) ...[
                          _buildSyndicateForm(),
                        ],

                        const SizedBox(height: 20),

                        // Submit Button
                        AppButton.primary(
                          text: _getSubmitButtonText(),
                          size: AppButtonSize.large,
                          isFullWidth: true,
                          isLoading: isLoading,
                          onPressed: _submitProfile,
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'تضمن نقابة المهندسين والمنصة حماية كافة البيانات وفق معايير الخصوصية الهندسية',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSubmitButtonText() {
    switch (widget.user.role) {
      case UserRole.engineer:
        return 'حفظ البيانات وطلب الاعتماد من نقابة المهندسين';
      case UserRole.client:
        return 'حفظ وتفعيل حساب صاحب المشروع والبدء';
      case UserRole.student:
        return 'حفظ بيانات القيد وتفعيل حساب الطالب المساعد';
      case UserRole.syndicate:
        return 'تأكيد الصلاحيات والدخول للوحة الرقابة والتحكيم';
    }
  }

  Widget _buildRoleHeaderBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bannerBg;
    Color borderColor;
    String title;
    String subtitle;

    switch (widget.user.role) {
      case UserRole.engineer:
        bannerBg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer;
        borderColor = isDark ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.3);
        title = 'إعداد ملف مهندس الديكور والمعماري';
        subtitle = 'قم بإدخال بياناتك المهنية ورقم عضويتك بالنقابة لتفعيل استقبال المشاريع وإسناد المهام.';
        break;
      case UserRole.client:
        bannerBg = isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
        borderColor = Theme.of(context).dividerColor;
        title = 'إعداد ملف صاحب المشروع / العقار';
        subtitle = 'حدد موقع عقارك ونوع الخدمات التي تحتاجها لتلقي أفضل العروض الهندسية والاستشارات.';
        break;
      case UserRole.student:
        bannerBg = isDark ? const Color(0xFF3B1A06) : const Color(0xFFFFEDD5);
        borderColor = isDark ? const Color(0xFFEA580C) : const Color(0xFFFDBA74);
        title = 'إعداد ملف طالب الهندسة والمساعد';
        subtitle = 'أدخل جامعتك ومهاراتك البرمجية لاستلام مهام الرسم والتدريب الميداني المعتمد.';
        break;
      case UserRole.syndicate:
        bannerBg = isDark ? const Color(0xFF270E4A) : const Color(0xFFEDE9FE);
        borderColor = isDark ? const Color(0xFF7E22CE) : const Color(0xFFC4B5FD);
        title = 'إعداد ملف ممثل نقابة المهندسين';
        subtitle = 'توثيق صلاحيات المراجعة، فض المنازعات، ونشر أدلة الإعمار والمواصفات المعتمدة.';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppBadge.role(widget.user.role.name),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. ENGINEER FORM (مهندس ديكور ومعماري)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEngineerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card 1: المهندس والمكتب
        AppCard(
          title: 'البيانات المهنية والتواصل',
          subtitle: 'المعلومات التي ستظهر للملاك وأصحاب المشاريع',
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'الاسم واللقب الهندسي *',
                hint: 'مثال: م. يوسف أحمد الغول',
                controller: _fullNameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال الاسم الهندسي' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'اسم المكتب الهندسي / الاستوديو (اختياري)',
                hint: 'مثال: استوديو إعمار للهندسة والتصميم الداخلي',
                controller: _officeNameController,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'رقم الهاتف والواتساب المخصص للعمل *',
                hint: '0599765432',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
              ),
              const SizedBox(height: 12),

              AppDropdown<String>(
                label: 'مكان تواجد المكتب / نطاق العمل في غزة *',
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
                label: 'نبذة عن الخبرات وفلسفة التصميم بالمواد البديلة',
                hint: 'اكتب نبذة عن تخصصك في استغلال الركام المعالج، الحلول الاقتصادية، وإعادة تأهيل المباني المتضررة...',
                controller: _bioController,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 2: الاعتماد النقابي والتخصصات
        AppCard(
          title: 'بيانات الاعتماد النقابي والخبرة',
          subtitle: 'يتم التحقق منها من قبل لجنة التدقيق بنقابة المهندسين',
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'رقم عضوية نقابة المهندسين (غزة) *',
                hint: 'مثال: ENG-GZ-2018-4421',
                controller: _syndicateNumberController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال رقم العضوية النقابية' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'سنوات الخبرة العملية الميدانية والتصميمية *',
                hint: '4',
                controller: _experienceYearsController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              AppChipSelector<String>(
                label: 'التخصصات الهندسية الدقيقة *',
                options: AppConstants.engineerSpecialties,
                selectedValues: _selectedEngineerSpecialties,
                labelBuilder: (s) => s,
                onChanged: (values) => setState(() => _selectedEngineerSpecialties = values),
                helperText: 'حدد مجالات خبرتك لتلقي طلبات العروض المناسبة.',
              ),
              const SizedBox(height: 12),

              AppChipSelector<String>(
                label: 'البرامج الهندسية المتقنة *',
                options: const ['AutoCAD', '3ds Max', 'Revit', 'SketchUp', 'Lumion', 'V-Ray', 'Photoshop'],
                selectedValues: _selectedEngineerSoftware,
                labelBuilder: (s) => s,
                onChanged: (values) => setState(() => _selectedEngineerSoftware = values),
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'وصف سابقة الأعمال (Portfolio Highlights)',
                hint: 'أبرز المشاريع السكنية أو التجارية المنجزة داخل قطاع غزة...',
                controller: _portfolioDescController,
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Degree Upload
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppTheme.borderRadius,
                  border: Border.all(
                    color: _degreeUploaded ? AppColors.success : Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'شهادة التخرج / بطاقة النقابة المعتمدة',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _degreeUploaded
                                ? 'تم إرفاق الملف: verified_engineer_degree.pdf ✓'
                                : 'مطلوبة لمنح شارة المهندس المعتمد وتوثيق العروض',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _degreeUploaded
                                  ? AppColors.success
                                  : (Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppButton.outline(
                      text: _degreeUploaded ? 'تغيير الشهادة' : 'رفع الشهادة',
                      size: AppButtonSize.small,
                      onPressed: () {
                        setState(() => _degreeUploaded = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إرفاق شهادة الاعتماد الهندسي بنجاح'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. CLIENT FORM (صاحب مشروع / عميل)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildClientForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card 1: بيانات صاحب العقار
        AppCard(
          title: 'بيانات المالك والتواصل',
          subtitle: 'تستخدم لتواصل المهندسين وإرسال عروض الأسعار والاستشارات',
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'اسم المالك أو المفوض عن العقار *',
                hint: 'مثال: أبو أحمد النجار',
                controller: _fullNameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال اسم صاحب العقار' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'رقم الهاتف والواتساب الرئيسي *',
                hint: '0599123456',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
              ),
              const SizedBox(height: 12),

              AppDropdown<String>(
                label: 'المحافظة / المدينة المقيم بها *',
                value: _selectedCity,
                items: AppConstants.gazaCities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 2: تفاصيل العقار والاحتياج
        AppCard(
          title: 'بيانات العقار والخدمات المطلوبة',
          subtitle: 'تساعد المهندسين في تقديم العروض المناسبة لميزانيتك واحتياجك',
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'العنوان التفصيلي وموقع العقار *',
                hint: 'مثال: غزة - تل الهوا - مقابل مدرسة تل الإسلام',
                controller: _propertyAddressController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال عنوان العقار' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AppDropdown<String>(
                      label: 'نوع العقار *',
                      value: _selectedPropertyType,
                      items: const [
                        DropdownMenuItem(value: 'شقة سكنية', child: Text('شقة سكنية')),
                        DropdownMenuItem(value: 'منزل منفصل / فيلا', child: Text('منزل منفصل / فيلا')),
                        DropdownMenuItem(value: 'محل تجاري / متجر', child: Text('محل تجاري / متجر')),
                        DropdownMenuItem(value: 'مكتب / عيادة', child: Text('مكتب / عيادة')),
                        DropdownMenuItem(value: 'مبنى / عمارة', child: Text('مبنى / عمارة')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPropertyType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      label: 'المساحة التقريبية (م²) *',
                      hint: '120',
                      controller: _propertyAreaController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              AppChipSelector<String>(
                label: 'طبيعة الخدمات التي تبحث عنها *',
                options: AppConstants.clientProjectTypes,
                selectedValues: _selectedClientNeeds,
                labelBuilder: (t) => t,
                onChanged: (values) => setState(() => _selectedClientNeeds = values),
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'وصف حالة العقار أو طبيعة الأضرار والاحتياج',
                hint: 'مثال: أضرار في القواطع الجنوبية للصالون، نحتاج توزيع فراغات بديكور مودرن ومواد بديلة خفيفة...',
                controller: _propertyNotesController,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. STUDENT FORM (طالب هندسة متدرب)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStudentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card 1: البيانات الشخصية والأكاديمية
        AppCard(
          title: 'البيانات الأكاديمية والدراسة',
          subtitle: 'يتم مراجعة القيد الجامعي لإسناد المهام الجزئية المدفوعة',
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'اسم الطالب الرباعي *',
                hint: 'مثال: أحمد سالم النجار',
                controller: _fullNameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال اسم الطالب' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'رقم الهاتف والواتساب للتواصل واستلام المهام *',
                hint: '0599112233',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
              ),
              const SizedBox(height: 12),

              AppDropdown<String>(
                label: 'الجامعة المقيد بها حالياً في غزة *',
                value: _selectedUniversity,
                items: AppConstants.gazaUniversities.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedUniversity = val);
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AppDropdown<String>(
                      label: 'القسم الأكاديمي *',
                      value: _selectedDepartment,
                      items: AppConstants.studentDepartments.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDepartment = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppDropdown<int>(
                      label: 'السنة الدراسية *',
                      value: _selectedYearOfStudy,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('السنة الأولى')),
                        DropdownMenuItem(value: 2, child: Text('السنة الثانية')),
                        DropdownMenuItem(value: 3, child: Text('السنة الثالثة')),
                        DropdownMenuItem(value: 4, child: Text('السنة الرابعة')),
                        DropdownMenuItem(value: 5, child: Text('السنة 5 (تخرج)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedYearOfStudy = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 2: المهارات وساعات التفرغ
        AppCard(
          title: 'المهارات البرمجية والجاهزية للعمل',
          subtitle: 'تساعد المهندسين في ترشيحك لمهام الرسم والرفع ثلاثي الأبعاد',
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppChipSelector<String>(
                label: 'البرامج والمهارات الهندسية المتقنة *',
                options: AppConstants.studentSkills,
                selectedValues: _selectedStudentSkills,
                labelBuilder: (s) => s,
                onChanged: (values) => setState(() => _selectedStudentSkills = values),
                helperText: 'يتم إسناد المهام بناءً على البرامج التي تحددها.',
              ),
              const SizedBox(height: 12),

              AppDropdown<String>(
                label: 'ساعات التفرغ الأسبوعية للتدريب وإنجاز المهام *',
                value: _availableHoursPerWeek,
                items: const [
                  DropdownMenuItem(value: '10 ساعات أسبوعياً', child: Text('10 ساعات أسبوعياً (جزئي)')),
                  DropdownMenuItem(value: '20 ساعة أسبوعياً', child: Text('20 ساعة أسبوعياً (متوسط)')),
                  DropdownMenuItem(value: '30 ساعة فأكثر', child: Text('30 ساعة فأكثر (تفرغ شبه كامل)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _availableHoursPerWeek = val);
                },
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'نبذة عن مهاراتك ومشاريعك الجامعية (Bio)',
                hint: 'أبرز المشاريع التي قمت برسمها أو تصميمها في مساقات الكلية...',
                controller: _bioController,
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Student ID Upload
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppTheme.borderRadius,
                  border: Border.all(
                    color: _studentIdUploaded ? AppColors.success : Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إثبات القيد الجامعي / البطاقة الجامعية',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _studentIdUploaded
                                ? 'تم إرفاق إثبات القيد: student_id_iug.pdf ✓'
                                : 'مطلوبة لمنح شارة الطالب المعتمد لتلقي المكافآت',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _studentIdUploaded
                                  ? AppColors.success
                                  : (Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppButton.outline(
                      text: _studentIdUploaded ? 'تغيير الإثبات' : 'رفع البطاقة',
                      size: AppButtonSize.small,
                      onPressed: () {
                        setState(() => _studentIdUploaded = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إرفاق إثبات القيد الجامعي بنجاح'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              CheckboxListTile(
                value: _availableForInternship,
                onChanged: (val) {
                  if (val != null) setState(() => _availableForInternship = val);
                },
                title: const Text(
                  'جاهز لتلقي إشعارات المهام المستعجلة والمكافآت المالية بالدولار',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.studentRole,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. SYNDICATE FORM (نقابة المهندسين)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSyndicateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          title: 'بيانات المسؤول النقابي والتواصل',
          subtitle: 'صلاحيات الإشراف، اعتماد المكاتب الهندسية، وفض النزاعات',
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'اسم المهندس المسؤول / المفوض *',
                hint: 'مثال: م. خالد الرنتيسي',
                controller: _fullNameController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال اسم المسؤول النقابي' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'رقم الهاتف المباشر للاتصال والتحكيم *',
                hint: '0599887766',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
              ),
              const SizedBox(height: 12),

              AppDropdown<String>(
                label: 'الفرع النقابي التابع له *',
                value: _selectedSyndicateBranch,
                items: const [
                  DropdownMenuItem(value: 'مقر النقابة الرئيسي - مدينة غزة', child: Text('مقر النقابة الرئيسي - مدينة غزة')),
                  DropdownMenuItem(value: 'فرع نقابة المهندسين - المنطقة الوسطى', child: Text('فرع نقابة المهندسين - المنطقة الوسطى')),
                  DropdownMenuItem(value: 'فرع نقابة المهندسين - خانيونس', child: Text('فرع نقابة المهندسين - خانيونس')),
                  DropdownMenuItem(value: 'فرع نقابة المهندسين - شمال غزة', child: Text('فرع نقابة المهندسين - شمال غزة')),
                  DropdownMenuItem(value: 'فرع نقابة المهندسين - رفح', child: Text('فرع نقابة المهندسين - رفح')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSyndicateBranch = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        AppCard(
          title: 'التفويض الإداري والصلاحيات الرقابية',
          subtitle: 'تخولك بنشر أدلة الإعمار، إصدار قرارات التحكيم، واعتماد التوثيق',
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'المسمى الوظيفي النقابي *',
                hint: 'مثال: مقرر لجنة التحكيم والاعتماد الهندسي',
                controller: _officialTitleController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال المسمى النقابي' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'الدائرة / اللجنة النقابية المختصة *',
                hint: 'مثال: دائرة المواصفات ولجنة الطوارئ وإعادة الإعمار',
                controller: _departmentController,
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال اسم الدائرة' : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'رقم قرار التكليف أو التفويض الإداري *',
                hint: 'مثال: RES-GZ-2024/119',
                controller: _resolutionNumberController,
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSuccessContainer
                      : AppColors.successContainer,
                  borderRadius: AppTheme.borderRadius,
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كتاب التفويض النقابي المعتمد',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'تم تفعيل صلاحيات الرقابة والتحكيم بقرار مجلس النقابة - محافظات غزة ✓',
                            style: TextStyle(fontSize: 11.5, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
