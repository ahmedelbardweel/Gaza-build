import 'package:equatable/equatable.dart';

class ReconstructionGuide extends Equatable {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String fullContent;
  final List<String> approvedMaterials;
  final String author;
  final DateTime publishedDate;

  const ReconstructionGuide({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.fullContent,
    this.approvedMaterials = const [],
    this.author = 'اللجنة الفنية - نقابة المهندسين غزة',
    required this.publishedDate,
  });

  factory ReconstructionGuide.fromJson(Map<String, dynamic> json) {
    return ReconstructionGuide(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'مواد بديلة',
      summary: json['summary'] as String? ?? '',
      fullContent: json['full_content'] as String? ?? '',
      approvedMaterials: (json['approved_materials'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      author: json['author'] as String? ?? 'نقابة المهندسين',
      publishedDate: json['published_date'] != null
          ? DateTime.tryParse(json['published_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'summary': summary,
      'full_content': fullContent,
      'approved_materials': approvedMaterials,
      'author': author,
      'published_date': publishedDate.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        summary,
        fullContent,
        approvedMaterials,
        author,
        publishedDate,
      ];
}

class ArbitrationCase extends Equatable {
  final String id;
  final String projectId;
  final String projectTitle;
  final String clientId;
  final String clientName;
  final String engineerId;
  final String engineerName;
  final String disputeReason;
  final String requestedResolution;
  final String? syndicateRuling;
  final String status; // 'pending_review', 'in_hearing', 'resolved'
  final DateTime createdAt;

  const ArbitrationCase({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.clientName,
    required this.engineerId,
    required this.engineerName,
    required this.disputeReason,
    required this.requestedResolution,
    this.syndicateRuling,
    this.status = 'pending_review',
    required this.createdAt,
  });

  factory ArbitrationCase.fromJson(Map<String, dynamic> json) {
    return ArbitrationCase(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      projectTitle: json['project_title'] as String? ?? '',
      clientId: json['client_id'] as String? ?? '',
      clientName: json['client_name'] as String? ?? '',
      engineerId: json['engineer_id'] as String? ?? '',
      engineerName: json['engineer_name'] as String? ?? '',
      disputeReason: json['dispute_reason'] as String? ?? '',
      requestedResolution: json['requested_resolution'] as String? ?? '',
      syndicateRuling: json['syndicate_ruling'] as String?,
      status: json['status'] as String? ?? 'pending_review',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'project_title': projectTitle,
      'client_id': clientId,
      'client_name': clientName,
      'engineer_id': engineerId,
      'engineer_name': engineerName,
      'dispute_reason': disputeReason,
      'requested_resolution': requestedResolution,
      'syndicate_ruling': syndicateRuling,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ArbitrationCase copyWith({
    String? id,
    String? projectId,
    String? projectTitle,
    String? clientId,
    String? clientName,
    String? engineerId,
    String? engineerName,
    String? disputeReason,
    String? requestedResolution,
    String? syndicateRuling,
    String? status,
    DateTime? createdAt,
  }) {
    return ArbitrationCase(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      engineerId: engineerId ?? this.engineerId,
      engineerName: engineerName ?? this.engineerName,
      disputeReason: disputeReason ?? this.disputeReason,
      requestedResolution: requestedResolution ?? this.requestedResolution,
      syndicateRuling: syndicateRuling ?? this.syndicateRuling,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        projectTitle,
        clientId,
        clientName,
        engineerId,
        engineerName,
        disputeReason,
        requestedResolution,
        syndicateRuling,
        status,
        createdAt,
      ];
}

class SectorStatistics extends Equatable {
  final int totalVerifiedEngineers;
  final int totalActiveStudents;
  final int totalReconstructionProjects;
  final double totalReconstructedAreaM2;
  final double estimatedContractVolumeUsd;
  final double studentEarnedIncomeUsd;

  const SectorStatistics({
    this.totalVerifiedEngineers = 142,
    this.totalActiveStudents = 380,
    this.totalReconstructionProjects = 215,
    this.totalReconstructedAreaM2 = 45600.0,
    this.estimatedContractVolumeUsd = 1280000.0,
    this.studentEarnedIncomeUsd = 94500.0,
  });

  @override
  List<Object?> get props => [
        totalVerifiedEngineers,
        totalActiveStudents,
        totalReconstructionProjects,
        totalReconstructedAreaM2,
        estimatedContractVolumeUsd,
        studentEarnedIncomeUsd,
      ];
}
