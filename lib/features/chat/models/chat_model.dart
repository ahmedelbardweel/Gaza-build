import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final String? attachmentUrl;
  final DateTime timestamp;
  final bool isQuickConsult;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    this.attachmentUrl,
    required this.timestamp,
    this.isQuickConsult = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final dateStr = json['created_at'] ?? json['timestamp'];
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? '',
      senderRole: json['sender_role'] as String? ?? 'client',
      text: json['text'] as String? ?? '',
      attachmentUrl: json['attachment_url'] as String?,
      timestamp: dateStr != null
          ? DateTime.tryParse(dateStr.toString()) ?? DateTime.now()
          : DateTime.now(),
      isQuickConsult: json['is_quick_consult'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson([String? conversationKey]) {
    final map = <String, dynamic>{
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'text': text,
      'attachment_url': attachmentUrl,
      'created_at': timestamp.toIso8601String(),
      'is_quick_consult': isQuickConsult,
    };
    if (conversationKey != null) {
      map['conversation_key'] = conversationKey;
    }
    return map;
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderRole,
        text,
        attachmentUrl,
        timestamp,
        isQuickConsult,
      ];
}

class ConsultationSession extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final String expertId;
  final String expertName;
  final String expertRole;
  final String topic;
  final double feeUsd;
  final String status; // 'active', 'closed'
  final DateTime createdAt;

  const ConsultationSession({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.expertId,
    required this.expertName,
    required this.expertRole,
    required this.topic,
    this.feeUsd = 5.0,
    this.status = 'active',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        clientId,
        clientName,
        expertId,
        expertName,
        expertRole,
        topic,
        feeUsd,
        status,
        createdAt,
      ];
}
