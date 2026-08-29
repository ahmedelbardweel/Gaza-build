import 'package:equatable/equatable.dart';

enum ProjectStatus {
  bidding,
  inProgress,
  completed,
  disputed;

  static ProjectStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return ProjectStatus.inProgress;
      case 'completed':
        return ProjectStatus.completed;
      case 'disputed':
        return ProjectStatus.disputed;
      case 'bidding':
      default:
        return ProjectStatus.bidding;
    }
  }

  String get dbValue {
    switch (this) {
      case ProjectStatus.inProgress:
        return 'in_progress';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.disputed:
        return 'disputed';
      case ProjectStatus.bidding:
        return 'bidding';
    }
  }

  String get displayName {
    switch (this) {
      case ProjectStatus.bidding:
        return 'متاح لتقديم العروض';
      case ProjectStatus.inProgress:
        return 'قيد التنفيذ والمتابعة';
      case ProjectStatus.completed:
        return 'مكتمل ومسلّم';
      case ProjectStatus.disputed:
        return 'نزاع لدى النقابة';
    }
  }
}

class ProjectMilestone extends Equatable {
  final String id;
  final String title;
  final String description;
  final int percentageWeight;
  final bool isCompleted;
  final double paymentAmountUsd;
  final bool isPaid;
  final String? proofImageUrl;
  final String? completedAt;

  const ProjectMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.percentageWeight,
    this.isCompleted = false,
    this.paymentAmountUsd = 0.0,
    this.isPaid = false,
    this.proofImageUrl,
    this.completedAt,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    return ProjectMilestone(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      percentageWeight: json['percentage_weight'] as int? ?? 25,
      isCompleted: json['is_completed'] as bool? ?? false,
      paymentAmountUsd: (json['payment_amount_usd'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['is_paid'] as bool? ?? false,
      proofImageUrl: json['proof_image_url'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'percentage_weight': percentageWeight,
      'is_completed': isCompleted,
      'payment_amount_usd': paymentAmountUsd,
      'is_paid': isPaid,
      'proof_image_url': proofImageUrl,
      'completed_at': completedAt,
    };
  }

  ProjectMilestone copyWith({
    String? id,
    String? title,
    String? description,
    int? percentageWeight,
    bool? isCompleted,
    double? paymentAmountUsd,
    bool? isPaid,
    String? proofImageUrl,
    String? completedAt,
  }) {
    return ProjectMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      percentageWeight: percentageWeight ?? this.percentageWeight,
      isCompleted: isCompleted ?? this.isCompleted,
      paymentAmountUsd: paymentAmountUsd ?? this.paymentAmountUsd,
      isPaid: isPaid ?? this.isPaid,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        percentageWeight,
        isCompleted,
        paymentAmountUsd,
        isPaid,
        proofImageUrl,
        completedAt,
      ];
}

class ProjectBid extends Equatable {
  final String id;
  final String projectId;
  final String engineerId;
  final String engineerName;
  final String engineerSpecialty;
  final double engineerRating;
  final double proposedPriceUsd;
  final int estimatedDurationDays;
  final String proposalMessage;
  final String moodBoardDescription;
  final List<String> moodBoardImages;
  final String status; // 'pending', 'accepted', 'rejected'
  final List<ProjectMilestone> proposedMilestones;
  final DateTime createdAt;

  const ProjectBid({
    required this.id,
    required this.projectId,
    required this.engineerId,
    required this.engineerName,
    this.engineerSpecialty = 'تصميم داخلي ومعماري',
    this.engineerRating = 5.0,
    required this.proposedPriceUsd,
    required this.estimatedDurationDays,
    required this.proposalMessage,
    this.moodBoardDescription = '',
    this.moodBoardImages = const [],
    this.status = 'pending',
    this.proposedMilestones = const [],
    required this.createdAt,
  });

  factory ProjectBid.fromJson(Map<String, dynamic> json) {
    return ProjectBid(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      engineerId: json['engineer_id'] as String? ?? '',
      engineerName: json['engineer_name'] as String? ?? '',
      engineerSpecialty: json['engineer_specialty'] as String? ?? 'تصميم داخلي ومعماري',
      engineerRating: (json['engineer_rating'] as num?)?.toDouble() ?? 5.0,
      proposedPriceUsd: (json['proposed_price_usd'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationDays: json['estimated_duration_days'] as int? ?? 14,
      proposalMessage: json['proposal_message'] as String? ?? '',
      moodBoardDescription: json['mood_board_description'] as String? ?? '',
      moodBoardImages: (json['mood_board_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'pending',
      proposedMilestones: (json['proposed_milestones'] as List<dynamic>?)
              ?.map((e) => ProjectMilestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'engineer_id': engineerId,
      'engineer_name': engineerName,
      'engineer_specialty': engineerSpecialty,
      'engineer_rating': engineerRating,
      'proposed_price_usd': proposedPriceUsd,
      'estimated_duration_days': estimatedDurationDays,
      'proposal_message': proposalMessage,
      'mood_board_description': moodBoardDescription,
      'mood_board_images': moodBoardImages,
      'status': status,
      if (proposedMilestones.isNotEmpty)
        'proposed_milestones': proposedMilestones.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProjectBid copyWith({
    String? id,
    String? projectId,
    String? engineerId,
    String? engineerName,
    String? engineerSpecialty,
    double? engineerRating,
    double? proposedPriceUsd,
    int? estimatedDurationDays,
    String? proposalMessage,
    String? moodBoardDescription,
    List<String>? moodBoardImages,
    String? status,
    List<ProjectMilestone>? proposedMilestones,
    DateTime? createdAt,
  }) {
    return ProjectBid(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      engineerId: engineerId ?? this.engineerId,
      engineerName: engineerName ?? this.engineerName,
      engineerSpecialty: engineerSpecialty ?? this.engineerSpecialty,
      engineerRating: engineerRating ?? this.engineerRating,
      proposedPriceUsd: proposedPriceUsd ?? this.proposedPriceUsd,
      estimatedDurationDays:
          estimatedDurationDays ?? this.estimatedDurationDays,
      proposalMessage: proposalMessage ?? this.proposalMessage,
      moodBoardDescription:
          moodBoardDescription ?? this.moodBoardDescription,
      moodBoardImages: moodBoardImages ?? this.moodBoardImages,
      status: status ?? this.status,
      proposedMilestones: proposedMilestones ?? this.proposedMilestones,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        engineerId,
        engineerName,
        engineerSpecialty,
        engineerRating,
        proposedPriceUsd,
        estimatedDurationDays,
        proposalMessage,
        moodBoardDescription,
        moodBoardImages,
        status,
        proposedMilestones,
        createdAt,
      ];
}

class Project extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final String title;
  final String description;
  final String projectType;
  final double areaM2;
  final double approximateBudgetUsd;
  final String preferredStyle;
  final String city;
  final String detailedAddress;
  final List<String> sitePhotos;
  final ProjectStatus status;
  final String? selectedEngineerId;
  final String? selectedEngineerName;
  final double? agreedPriceUsd;
  final bool isEscrowSecured;
  final int completionPercentage;
  final List<ProjectBid> bids;
  final List<ProjectMilestone> milestones;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.title,
    required this.description,
    required this.projectType,
    required this.areaM2,
    required this.approximateBudgetUsd,
    required this.preferredStyle,
    required this.city,
    this.detailedAddress = '',
    this.sitePhotos = const [],
    this.status = ProjectStatus.bidding,
    this.selectedEngineerId,
    this.selectedEngineerName,
    this.agreedPriceUsd,
    this.isEscrowSecured = false,
    this.completionPercentage = 0,
    this.bids = const [],
    this.milestones = const [],
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      clientId: json['client_id'] as String? ?? '',
      clientName: json['client_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      projectType: json['project_type'] as String? ?? '',
      areaM2: (json['area_m2'] as num?)?.toDouble() ?? 0.0,
      approximateBudgetUsd: (json['approximate_budget_usd'] as num?)?.toDouble() ?? 0.0,
      preferredStyle: json['preferred_style'] as String? ?? '',
      city: json['city'] as String? ?? 'غزة',
      detailedAddress: json['detailed_address'] as String? ?? '',
      sitePhotos: (json['site_photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: ProjectStatus.fromString(json['status'] as String?),
      selectedEngineerId: json['selected_engineer_id'] as String?,
      selectedEngineerName: json['selected_engineer_name'] as String?,
      agreedPriceUsd: (json['agreed_price_usd'] as num?)?.toDouble(),
      isEscrowSecured: json['is_escrow_secured'] as bool? ?? false,
      completionPercentage: json['completion_percentage'] as int? ?? 0,
      bids: (json['bids'] as List<dynamic>?)
              ?.map((e) => ProjectBid.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => ProjectMilestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'title': title,
      'description': description,
      'project_type': projectType,
      'area_m2': areaM2,
      'approximate_budget_usd': approximateBudgetUsd,
      'preferred_style': preferredStyle,
      'city': city,
      'detailed_address': detailedAddress,
      'site_photos': sitePhotos,
      'status': status.dbValue,
      'selected_engineer_id': selectedEngineerId,
      'selected_engineer_name': selectedEngineerName,
      'agreed_price_usd': agreedPriceUsd,
      'is_escrow_secured': isEscrowSecured,
      'completion_percentage': completionPercentage,
      'bids': bids.map((b) => b.toJson()).toList(),
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Project copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? title,
    String? description,
    String? projectType,
    double? areaM2,
    double? approximateBudgetUsd,
    String? preferredStyle,
    String? city,
    String? detailedAddress,
    List<String>? sitePhotos,
    ProjectStatus? status,
    String? selectedEngineerId,
    String? selectedEngineerName,
    double? agreedPriceUsd,
    bool? isEscrowSecured,
    int? completionPercentage,
    List<ProjectBid>? bids,
    List<ProjectMilestone>? milestones,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      title: title ?? this.title,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      areaM2: areaM2 ?? this.areaM2,
      approximateBudgetUsd:
          approximateBudgetUsd ?? this.approximateBudgetUsd,
      preferredStyle: preferredStyle ?? this.preferredStyle,
      city: city ?? this.city,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      sitePhotos: sitePhotos ?? this.sitePhotos,
      status: status ?? this.status,
      selectedEngineerId: selectedEngineerId ?? this.selectedEngineerId,
      selectedEngineerName:
          selectedEngineerName ?? this.selectedEngineerName,
      agreedPriceUsd: agreedPriceUsd ?? this.agreedPriceUsd,
      isEscrowSecured: isEscrowSecured ?? this.isEscrowSecured,
      completionPercentage:
          completionPercentage ?? this.completionPercentage,
      bids: bids ?? this.bids,
      milestones: milestones ?? this.milestones,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        clientName,
        title,
        description,
        projectType,
        areaM2,
        approximateBudgetUsd,
        preferredStyle,
        city,
        detailedAddress,
        sitePhotos,
        status,
        selectedEngineerId,
        selectedEngineerName,
        agreedPriceUsd,
        isEscrowSecured,
        completionPercentage,
        bids,
        milestones,
        createdAt,
      ];
}
