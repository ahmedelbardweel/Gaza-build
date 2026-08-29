import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gaza_build/core/theme/app_colors.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/core/widgets/app_badge.dart';
import 'package:gaza_build/core/widgets/app_button.dart';
import 'package:gaza_build/core/widgets/app_loader.dart';
import 'package:gaza_build/core/widgets/app_scaffold.dart';
import 'package:gaza_build/core/widgets/app_text_field.dart';
import 'package:gaza_build/features/chat/models/chat_model.dart';
import 'package:gaza_build/shared/services/supabase_service.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  final String otherName;
  final String otherRole;

  const ChatScreen({
    super.key,
    required this.title,
    required this.otherName,
    required this.otherRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late String _conversationKey;
  bool _isLoading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  SupabaseClient? get _client => SupabaseService.instance.client;

  @override
  void initState() {
    super.initState();
    _conversationKey = 'conv_${widget.title.hashCode.abs()}';
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final client = _client;
    if (client == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await client
          .from('chat_messages')
          .select()
          .eq('conversation_key', _conversationKey)
          .order('created_at', ascending: true);

      final list = (res as List<dynamic>)
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(list);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[ChatScreen] Load messages error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final client = _client;
    final currentUser = client?.auth.currentUser;
    final currentUserId = currentUser?.id ?? 'user_anonymous';

    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      senderName: currentUser?.userMetadata?['full_name'] as String? ?? 'أنا',
      senderRole: currentUser?.userMetadata?['role'] as String? ?? 'client',
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(msg);
      _messageController.clear();
    });

    if (client != null) {
      try {
        await client.from('chat_messages').insert(msg.toJson(_conversationKey));
      } catch (e) {
        debugPrint('[ChatScreen] Send message error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      showBackButton: true,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: AppBadge.role(widget.otherRole),
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: AppLoader(
                      message: 'جاري جلب وتحديث رسائل المحادثة...',
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد رسائل سابقة. ابدأ المحادثة الآن.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final client = _client;
                          final isMe = msg.senderId == client?.auth.currentUser?.id ||
                              msg.senderId == 'me';

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                                  if (!isMe)
                                    Text(
                                      msg.senderName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isMe ? Colors.black : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.black54
                                          : (Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.darkTextMuted
                                              : AppColors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hint: 'اكتب رسالتك أو استفسارك هنا...',
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
