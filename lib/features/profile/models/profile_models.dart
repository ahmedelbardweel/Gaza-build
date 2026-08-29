import 'package:equatable/equatable.dart';

class EngineerProfile extends Equatable {
  final String userId;
  final String syndicateMembershipNumber;
  final String universityDegreeUrl;
  final int yearsOfExperience;
  final List<String> specialties;
  final String portfolioDescription;
  final List<String> portfolioProjectImages;
  final double rating;
  final int completedProjectsCount;

  const EngineerProfile({
    required this.userId,
    this.syndicateMembershipNumber = '',
    this.universityDegreeUrl = '',
    this.yearsOfExperience = 0,
    this.specialties = const [],
    this.portfolioDescription = '',
    this.portfolioProjectImages = const [],
    this.rating = 5.0,
    this.completedProjectsCount = 0,
  });

  factory EngineerProfile.fromJson(Map<String, dynamic> json) {
    return EngineerProfile(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      syndicateMembershipNumber: json['syndicate_membership_number'] as String? ?? '',
      universityDegreeUrl: json['university_degree_url'] as String? ?? '',
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      portfolioDescription: json['portfolio_description'] as String? ?? '',
      portfolioProjectImages: (json['portfolio_project_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      completedProjectsCount: json['completed_projects_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'syndicate_membership_number': syndicateMembershipNumber,
      'university_degree_url': universityDegreeUrl,
      'years_of_experience': yearsOfExperience,
      'specialties': specialties,
      'portfolio_description': portfolioDescription,
      'portfolio_project_images': portfolioProjectImages,
      'rating': rating,
      'completed_projects_count': completedProjectsCount,
    };
  }

  EngineerProfile copyWith({
    String? userId,
    String? syndicateMembershipNumber,
    String? universityDegreeUrl,
    int? yearsOfExperience,
    List<String>? specialties,
    String? portfolioDescription,
    List<String>? portfolioProjectImages,
    double? rating,
    int? completedProjectsCount,
  }) {
    return EngineerProfile(
      userId: userId ?? this.userId,
      syndicateMembershipNumber:
          syndicateMembershipNumber ?? this.syndicateMembershipNumber,
      universityDegreeUrl: universityDegreeUrl ?? this.universityDegreeUrl,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      specialties: specialties ?? this.specialties,
      portfolioDescription: portfolioDescription ?? this.portfolioDescription,
      portfolioProjectImages:
          portfolioProjectImages ?? this.portfolioProjectImages,
      rating: rating ?? this.rating,
      completedProjectsCount:
          completedProjectsCount ?? this.completedProjectsCount,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        syndicateMembershipNumber,
        universityDegreeUrl,
        yearsOfExperience,
        specialties,
        portfolioDescription,
        portfolioProjectImages,
        rating,
        completedProjectsCount,
      ];
}

class ClientProfile extends Equatable {
  final String userId;
  final String address;
  final List<String> preferredProjectTypes;
  final String propertyConditionNote;

  const ClientProfile({
    required this.userId,
    this.address = '',
    this.preferredProjectTypes = const [],
    this.propertyConditionNote = '',
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      address: json['address'] as String? ?? '',
      preferredProjectTypes: (json['preferred_project_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      propertyConditionNote: json['property_condition_note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'address': address,
      'preferred_project_types': preferredProjectTypes,
      'property_condition_note': propertyConditionNote,
    };
  }

  ClientProfile copyWith({
    String? userId,
    String? address,
    List<String>? preferredProjectTypes,
    String? propertyConditionNote,
  }) {
    return ClientProfile(
      userId: userId ?? this.userId,
      address: address ?? this.address,
      preferredProjectTypes:
          preferredProjectTypes ?? this.preferredProjectTypes,
      propertyConditionNote:
          propertyConditionNote ?? this.propertyConditionNote,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        address,
        preferredProjectTypes,
        propertyConditionNote,
      ];
}

class StudentProfile extends Equatable {
  final String userId;
  final String university;
  final String department;
  final int yearOfStudy;
  final String enrollmentProofUrl;
  final bool availableForInternship;
  final List<String> skills;
  final double mentorshipScore;
  final int completedMicroTasks;

  const StudentProfile({
    required this.userId,
    this.university = 'الجامعة الإسلامية بغزة (IUG)',
    this.department = 'الهندسة المعمارية (Architecture)',
    this.yearOfStudy = 3,
    this.enrollmentProofUrl = '',
    this.availableForInternship = true,
    this.skills = const [],
    this.mentorshipScore = 4.8,
    this.completedMicroTasks = 0,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      university: json['university'] as String? ?? '',
      department: json['department'] as String? ?? '',
      yearOfStudy: json['year_of_study'] as int? ?? 1,
      enrollmentProofUrl: json['enrollment_proof_url'] as String? ?? '',
      availableForInternship:
          json['available_for_internship'] as bool? ?? true,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      mentorshipScore: (json['mentorship_score'] as num?)?.toDouble() ?? 5.0,
      completedMicroTasks: json['completed_micro_tasks'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'university': university,
      'department': department,
      'year_of_study': yearOfStudy,
      'enrollment_proof_url': enrollmentProofUrl,
      'available_for_internship': availableForInternship,
      'skills': skills,
      'mentorship_score': mentorshipScore,
      'completed_micro_tasks': completedMicroTasks,
    };
  }

  StudentProfile copyWith({
    String? userId,
    String? university,
    String? department,
    int? yearOfStudy,
    String? enrollmentProofUrl,
    bool? availableForInternship,
    List<String>? skills,
    double? mentorshipScore,
    int? completedMicroTasks,
  }) {
    return StudentProfile(
      userId: userId ?? this.userId,
      university: university ?? this.university,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      enrollmentProofUrl: enrollmentProofUrl ?? this.enrollmentProofUrl,
      availableForInternship:
          availableForInternship ?? this.availableForInternship,
      skills: skills ?? this.skills,
      mentorshipScore: mentorshipScore ?? this.mentorshipScore,
      completedMicroTasks: completedMicroTasks ?? this.completedMicroTasks,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        university,
        department,
        yearOfStudy,
        enrollmentProofUrl,
        availableForInternship,
        skills,
        mentorshipScore,
        completedMicroTasks,
      ];
}

class SyndicateProfile extends Equatable {
  final String userId;
  final String officialTitle;
  final String department;
  final String authorizationDocumentUrl;

  const SyndicateProfile({
    required this.userId,
    this.officialTitle = 'مقرر لجنة التحكيم والاعتماد الهندسي',
    this.department = 'دائرة التخطيط والمواصفات الهندسية',
    this.authorizationDocumentUrl = '',
  });

  factory SyndicateProfile.fromJson(Map<String, dynamic> json) {
    return SyndicateProfile(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      officialTitle: json['official_title'] as String? ?? '',
      department: json['department'] as String? ?? '',
      authorizationDocumentUrl:
          json['authorization_document_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'official_title': officialTitle,
      'department': department,
      'authorization_document_url': authorizationDocumentUrl,
    };
  }

  SyndicateProfile copyWith({
    String? userId,
    String? officialTitle,
    String? department,
    String? authorizationDocumentUrl,
  }) {
    return SyndicateProfile(
      userId: userId ?? this.userId,
      officialTitle: officialTitle ?? this.officialTitle,
      department: department ?? this.department,
      authorizationDocumentUrl:
          authorizationDocumentUrl ?? this.authorizationDocumentUrl,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        officialTitle,
        department,
        authorizationDocumentUrl,
      ];
}
