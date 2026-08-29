import 'package:flutter/material.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/core/widgets/app_text_field.dart';
import 'package:gaza_build/features/chat/models/chat_model.dart';

class QuickConsultScreen extends StatefulWidget {
  const QuickConsultScreen({super.key});

  @override
  State<QuickConsultScreen> createState() => _QuickConsultScreenState();
}

class _QuickConsultScreenState extends State<QuickConsultScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      senderId: 'eng_system',
      senderName: 'م. يوسف الغول (استشاري ديكور معتمد)',
      senderRole: 'engineer',
      text: 'أهلاً بك! أنا متاح لمساعدتك في أي استشارة فورية تخص إعادة الإعمار، اختيار ألوان الدهانات، أو توزيع الأثاث.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isQuickConsult: true,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'صاحب الاستشارة',
      senderRole: 'client',
      text: text,
      timestamp: DateTime.now(),
      isQuickConsult: true,
    );

    setState(() {
      _messages.add(userMsg);
      _messageController.clear();
    });

    // Simulated quick expert response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            id: 'resp_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'eng_system',
            senderName: 'م. يوسف الغول (استشاري ديكور معتمد)',
            senderRole: 'engineer',
            text: 'شكراً لاستفسارك. أنصحك باعتماد درجات البيج الرملي المعماري لأنها تعكس ضوء النهار بشكل ممتاز في ظل نقص الكهرباء، مع استخدام جبس بورد معزول لتوفير التكلفة.',
            timestamp: DateTime.now(),
            isQuickConsult: true,
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'جلسة استشارة سريعة مع مهندس',
      showBackButton: true,
      body: Column(
        children: [
          // Header info bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFFFEF3C7),
            child: const Text(
              'استشارة مباشرة فورية • مدعومة بتوصيات نقابة المهندسين لمواد غزة البديلة',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderRole == 'client';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Theme.of(context).colorScheme.surface,
                      borderRadius: AppTheme.borderRadius,
                      border: Border.all(
                        color: isMe ? AppColors.primary : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.senderName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isMe ? Colors.black87 : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: isMe ? Colors.black : Theme.of(context).colorScheme.onSurface,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hint: 'اكتب سؤالك الهندسي هنا...',
                      controller: _messageController,
                      onFieldSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton.primary(
                    text: 'إرسال',
                    size: AppButtonSize.medium,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
