import 'package:flutter/material.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final List<_ChatHistory> _chatHistory = [
    _ChatHistory(
      title: 'Fonksiyonlar hakkında yardım',
      preview: 'Fonksiyonlarda tanım kümesini...',
      time: 'Bugün',
    ),
    _ChatHistory(
      title: 'Kuvvet ve hareket',
      preview: 'Newton yasalarını açıklar mısın?',
      time: 'Dün',
    ),
    _ChatHistory(
      title: 'Paragraf soruları',
      preview: 'Paragraf çözerken nelere dikkat...',
      time: '2 gün önce',
    ),
  ];

  final List<_ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  bool _isChatOpen = false;
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _isChatOpen = true;
    });
  }

  void _openHistory(_ChatHistory chat) {
    setState(() {
      _messages.clear();
      _isChatOpen = true;

      _messages.add(
        _ChatMessage(
          text: chat.preview,
          isUser: true,
        ),
      );

      _messages.add(
        const _ChatMessage(
          text:
          'Tabii! Bu konuda sana yardımcı olabilirim. '
              'Sorunu biraz daha detaylandırırsan birlikte inceleyebiliriz.',
          isUser: false,
        ),
      );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _messageController.clear();
      _isTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      setState(() {
        _isTyping = false;

        _messages.add(
          const _ChatMessage(
            text:
            'Anladım! 🤖 Bu şu anda demo AI arayüzü. '
                'Gerçek AI bağlantısı eklendiğinde sorunu detaylı şekilde '
                'cevaplayabileceğim.',
            isUser: false,
          ),
        );
      });
    });
  }

  void _goBackToChats() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isChatOpen = false;
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        leading: _isChatOpen
            ? IconButton(
          onPressed: _goBackToChats,
          icon: const Icon(Icons.arrow_back_rounded),
        )
            : null,
        title: Text(
          _isChatOpen ? 'Yeni Sohbet' : 'AI Koç',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isChatOpen)
            IconButton(
              onPressed: _startNewChat,
              tooltip: 'Yeni Sohbet',
              icon: const Icon(Icons.add_comment_outlined),
            ),
        ],
      ),
      body: _isChatOpen
          ? _buildChatScreen(theme, colors)
          : _buildHomeScreen(theme, colors, isDark),
    );
  }

  Widget _buildHomeScreen(
      ThemeData theme,
      ColorScheme colors,
      bool isDark,
      ) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6750A4),
                  Color(0xFF8B6CCB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6750A4).withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'AI Koçun Burada 🤖',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Derslerin, konuların ve çalışma planın '
                      'hakkında sorularını sorabilirsin.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _startNewChat,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text(
                      'Yeni Sohbet Başlat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6750A4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Geçmiş Sohbetler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              TextButton.icon(
                onPressed: _startNewChat,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Yeni'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_chatHistory.isEmpty)
            _buildEmptyHistory(colors)
          else
            ..._chatHistory.map(
                  (chat) => _ChatHistoryCard(
                chat: chat,
                onTap: () => _openHistory(chat),
              ),
            ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerHighest
                  : const Color(0xFFF7F3FD),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: colors.primary,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'AI Koçuna ders soruları, konu anlatımları '
                        've çalışma önerileri sorabilirsin.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 42,
            color: colors.onSurfaceVariant.withValues(alpha: 0.55),
          ),

          const SizedBox(height: 12),

          Text(
            'Henüz sohbet yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'İlk sohbetini başlatarak AI Koçuna soru sor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScreen(
      ThemeData theme,
      ColorScheme colors,
      ) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildChatWelcome(colors)
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                20,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _MessageBubble(
                  message: _messages[index],
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: colors.primaryContainer,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Koç yazıyor...',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          _buildMessageInput(theme, colors),
        ],
      ),
    );
  }

  Widget _buildChatWelcome(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 36,
                color: colors.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Nasıl yardımcı olabilirim?',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Bir konu sor, çalışma planın hakkında konuş '
                  'veya anlamadığın bir konuyu birlikte inceleyelim.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
      ThemeData theme,
      ColorScheme colors,
      ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: colors.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              style: TextStyle(
                color: colors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'AI Koçuna bir şey sor...',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.65),
                ),
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: colors.outline.withValues(alpha: 0.20),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: colors.outline.withValues(alpha: 0.20),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            onPressed: _isTyping ? null : _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              disabledBackgroundColor:
              colors.onSurface.withValues(alpha: 0.10),
            ),
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}

class _ChatHistory {
  final String title;
  final String preview;
  final String time;

  const _ChatHistory({
    required this.title,
    required this.preview,
    required this.time,
  });
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class _ChatHistoryCard extends StatelessWidget {
  final _ChatHistory chat;
  final VoidCallback onTap;

  const _ChatHistoryCard({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.20),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: colors.onPrimaryContainer,
          ),
        ),
        title: Text(
          chat.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            chat.preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              chat.time,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 300,
          ),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: colors.primaryContainer,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 310,
              ),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
