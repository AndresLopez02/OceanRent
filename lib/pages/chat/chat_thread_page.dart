import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/booking_model.dart';
import 'package:ocean_rent/models/chat_message_model.dart';
import 'package:ocean_rent/providers/chat_providers.dart';
import 'package:ocean_rent/utils/chat_utils.dart';

class ChatThreadPage extends ConsumerStatefulWidget {
  final BookingModel booking;
  final String title;
  final String subtitle;
  final String currentUserId;
  final bool isAdmin;

  const ChatThreadPage({
    super.key,
    required this.booking,
    required this.title,
    required this.subtitle,
    required this.currentUserId,
    required this.isAdmin,
  });

  @override
  ConsumerState<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends ConsumerState<ChatThreadPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final success = await ref
        .read(chatNotifierProvider)
        .sendMessage(
          bookingId: widget.booking.id,
          senderId: widget.currentUserId,
          senderRole: widget.isAdmin
              ? ChatMessageModel.senderRoleAdmin
              : ChatMessageModel.senderRoleCustomer,
          text: text,
        );

    if (!mounted) return;

    if (success) {
      _messageController.clear();
      _scrollToBottom();
    } else {
      final message =
          ref.read(chatNotifierProvider).errorMessage ??
          'No se pudo enviar el mensaje.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppTheme.animationFast,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.booking.id));
    final canSend = ChatAvailability.canSendMessages(widget.booking);
    final isSending = ref.watch(chatNotifierProvider).isSending;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.appBarTitleStyle,
            ),
            if (widget.subtitle.trim().isNotEmpty)
              Text(
                widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.white.withValues(alpha: AppTheme.alphaTextOnDark),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.oceanBlue),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: AppTheme.screenPadding,
                  child: Text(
                    'No se pudo cargar la conversación.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.alertRed),
                  ),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return _EmptyConversation(isAdmin: widget.isAdmin);
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: AppTheme.listPadding,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == widget.currentUserId;

                    return _MessageBubble(message: message, isMine: isMine);
                  },
                );
              },
            ),
          ),
          if (canSend)
            _MessageComposer(
              controller: _messageController,
              isSending: isSending,
              onSend: _sendMessage,
            )
          else
            const _ClosedConversationBanner(),
        ],
      ),
    );
  }
}
class _EmptyConversation extends StatelessWidget {
  final bool isAdmin;

  const _EmptyConversation({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppTheme.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.forum_outlined,
              color: AppTheme.oceanBlue,
              size: AppTheme.emptyStateIconSize,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Todavía no hay mensajes',
              style: AppTheme.titleMedium.copyWith(color: AppTheme.deepNavy),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              isAdmin
                  ? 'Escribe para iniciar la conversación con el cliente.'
                  : 'Escribe para resolver cualquier duda sobre tu reserva.',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppTheme.oceanBlue : AppTheme.surface;
    final textColor = isMine ? AppTheme.white : AppTheme.deepNavy;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppTheme.radiusLg),
      topRight: const Radius.circular(AppTheme.radiusLg),
      bottomLeft: Radius.circular(isMine ? AppTheme.radiusLg : AppTheme.radiusXs),
      bottomRight: Radius.circular(isMine ? AppTheme.radiusXs : AppTheme.radiusLg),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing10),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing14,
          vertical: AppTheme.spacing10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: radius,
          border: isMine
              ? null
              : Border.all(
                  color: AppTheme.deepNavy.withValues(alpha: AppTheme.alphaSoft),
                ),
          boxShadow: AppTheme.softShadow(alpha: AppTheme.alphaUltraSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTheme.bodyMedium.copyWith(
                color: textColor,
                height: AppTheme.lineHeightSmall,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              _formatTime(message.createdAt),
              style: AppTheme.labelSmall.copyWith(
                color: isMine
                    ? AppTheme.white.withValues(alpha: AppTheme.alphaTextOnDark)
                    : AppTheme.textSecondary,
                fontSize: AppTheme.fontSize11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.deepNavy.withValues(alpha: AppTheme.alphaSoft),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  counterText: '',
                  filled: true,
                  fillColor: AppTheme.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppTheme.borderRadiusBadge,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppTheme.borderRadiusBadge,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppTheme.borderRadiusBadge,
                    borderSide: const BorderSide(
                      color: AppTheme.oceanBlue,
                      width: AppTheme.borderWidthMedium,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacing8),
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
              child: Material(
                color: AppTheme.deepNavy,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isSending ? null : onSend,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    child: isSending
                        ? const SizedBox(
                            width: AppTheme.iconSizeLarge,
                            height: AppTheme.iconSizeLarge,
                            child: CircularProgressIndicator(
                              strokeWidth: AppTheme.progressStrokeWidth,
                              color: AppTheme.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AppTheme.white,
                            size: AppTheme.iconSizeLarge,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosedConversationBanner extends StatelessWidget {
  const _ClosedConversationBanner();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.deepNavy.withValues(alpha: AppTheme.alphaSoft),
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              color: AppTheme.textMuted,
              size: AppTheme.iconSizeLarge,
            ),
            const SizedBox(width: AppTheme.spacing10),
            Expanded(
              child: Text(
                'El chat está cerrado porque la actividad ya ha finalizado.',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime? date) {
  if (date == null) return '';

  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month · $hour:$minute';
}
