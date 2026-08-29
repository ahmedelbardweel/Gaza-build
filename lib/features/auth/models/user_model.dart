import 'package:equatable/equatable.dart';

enum UserRole {
  client,
  engineer,
  student,
  syndicate;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'engineer':
        return UserRole.engineer;
      case 'student':
        return UserRole.student;
      case 'syndicate':
        return UserRole.syndicate;
      case 'client':
      default:
        return UserRole.client;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'صاحب مشروع / عميل';
      case UserRole.engineer:
        return 'مهندس ديكور / معماري';
      case UserRole.student:
        return 'طالب هندسة / متدرب';
      case UserRole.syndicate:
        return 'نقابة المهندسين (إشراف)';
    }
  }
}

enum VerificationStatus {
  unsubmitted,
  pending,
  approved,
  rejected;

  static VerificationStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
      case 'verified':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'unsubmitted':
      default:
        return VerificationStatus.unsubmitted;
    }
  }

  String get displayName {
    switch (this) {
      case VerificationStatus.approved:
        return 'معتمد وموثق';
      case VerificationStatus.pending:
        return 'قيد مراجعة النقابة';
      case VerificationStatus.rejected:
        return 'مرفوض - يلزم تعديل';
      case VerificationStatus.unsubmitted:
        return 'غير مكتمل';
    }
  }
}

class BaseProfile extends Equatable {
  final String id;
  final String email;
  final UserRole role;
  final String fullName;
  final String phone;
  final String city;
  final String avatarUrl;
  final String bio;
  final bool isProfileComplete;
  final VerificationStatus verificationStatus;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BaseProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName = '',
    this.phone = '',
    this.city = 'غزة',
    this.avatarUrl = '',
    this.bio = '',
    this.isProfileComplete = false,
    this.verificationStatus = VerificationStatus.unsubmitted,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BaseProfile.fromJson(Map<String, dynamic> json) {
    return BaseProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? 'غزة',
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      verificationStatus: VerificationStatus.fromString(json['verification_status'] as String?),
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'full_name': fullName,
      'phone': phone,
      'city': city,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_profile_complete': isProfileComplete,
      'verification_status': verificationStatus.name,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BaseProfile copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    String? phone,
    String? city,
    String? avatarUrl,
    String? bio,
    bool? isProfileComplete,
    VerificationStatus? verificationStatus,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BaseProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        fullName,
        phone,
        city,
        avatarUrl,
        bio,
        isProfileComplete,
        verificationStatus,
        rejectionReason,
        createdAt,
        updatedAt,
      ];
}
