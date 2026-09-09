// lib/modules/study/screens/ai_chat_screen.dart
//
// Gerçek Gemini API'ye bağlı sohbet ekranı.
// Mesajlar SQLite'a kaydedilir, oturum bazlı geçmiş tutulur.

import 'package:flutter/material.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/ai_service.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _msgCtrl      = TextEditingController();
  final _scrollCtrl   = ScrollController();
  final List<_Msg>    _messages  = [];
  List<ChatSession>   _sessions  = [];
  ChatSession?        _current;
  bool                _isTyping  = false;
  bool                _loadingSessions = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Oturum Yönetimi ────────────────────────────────────────

  Future<void> _loadSessions() async {
    final list = await DatabaseService.instance.getAllChatSessions();
    if (mounted) setState(() { _sessions = list; _loadingSessions = false; });
  }

  Future<void> _startNewSession() async {
    final session = await DatabaseService.instance.createChatSession(
      'Yeni Sohbet ${DateTime.now().day}.${DateTime.now().month}',
    );
    setState(() {
      _sessions.insert(0, session);
      _current = session;
      _messages.clear();
    });
  }

  Future<void> _openSession(ChatSession session) async {
    final rows = await DatabaseService.instance.getMessages(session.id);
    setState(() {
      _current = session;
      _messages
        ..clear()
        ..addAll(rows.map((r) => _Msg(text: r.text, isUser: r.isUser)));
    });
    _scrollToBottom();
  }

  // ── Mesaj Gönderme ─────────────────────────────────────────

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isTyping) return;

    // Oturum yoksa oluştur
    if (_current == null) await _startNewSession();

    _msgCtrl.clear();

    // 1. Kullanıcı mesajını ekle
    setState(() {
      _messages.add(_Msg(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // 2. DB'ye kaydet
    await DatabaseService.instance.saveMessage(
      sessionId: _current!.id,
      text: text,
      isUser: true,
    );

    // 3. AI'ya gönder
    try {
      final history = _messages
          .where((m) => !m.isTyping)
          .map((m) => AiMessage(text: m.text, isUser: m.isUser))
          .toList();

      final reply = await AiService.instance.sendText(
        message: text,
        history: history.length > 1
            ? history.sublist(0, history.length - 1)
            : [],
      );

      // 4. AI cevabını ekle + kaydet
      setState(() {
        _isTyping = false;
        _messages.add(_Msg(text: reply, isUser: false));
      });

      await DatabaseService.instance.saveMessage(
        sessionId: _current!.id,
        text: reply,
        isUser: false,
      );

      // 5. Oturumun başlığını güncelle (ilk mesajdan al)
      if (_messages.length == 2) {
        final title = text.length > 40
            ? '${text.substring(0, 40)}...'
            : text;
        await DatabaseService.instance.deleteChatSession(_current!.id);
        final updated = await DatabaseService.instance
            .createChatSession(title);
        // Mesajları yeni oturuma taşı
        for (final m in _messages) {
          await DatabaseService.instance.saveMessage(
            sessionId: updated.id,
            text: m.text,
            isUser: m.isUser,
          );
        }
        setState(() => _current = updated);
        await _loadSessions();
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(_Msg(text: '⚠️ $e', isUser: false));
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _current?.title ?? 'AI Asistan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Geçmiş oturumlar
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Sohbet Geçmişi',
            onPressed: () => _showSessionsSheet(),
          ),
          // Yeni sohbet
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Yeni Sohbet',
            onPressed: _startNewSession,
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Mesaj Listesi ────────────────────────────────────
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(onStart: _startNewSession)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount:
                        _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_isTyping && i == _messages.length) {
                        return const _TypingBubble();
                      }
                      return _MessageBubble(msg: _messages[i]);
                    },
                  ),
          ),

          // ── Giriş Alanı ─────────────────────────────────────
          _InputBar(
            controller: _msgCtrl,
            isTyping: _isTyping,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  // ── Oturum Listesi Bottom Sheet ────────────────────────────

  void _showSessionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => _loadingSessions
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(child: Text('Henüz sohbet yok.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (ctx, i) {
                    final s = _sessions[i];
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline_rounded),
                      title: Text(s.title),
                      subtitle: Text(
                        '${s.updatedAt.day}.${s.updatedAt.month}.${s.updatedAt.year}',
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openSession(s);
                      },
                    );
                  },
                ),
    );
  }
}

// ── Veri Modeli ────────────────────────────────────────────────

class _Msg {
  final String text;
  final bool   isUser;
  final bool   isTyping;
  const _Msg({required this.text, required this.isUser, this.isTyping = false});
}

// ── Widgets ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyState({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 64, color: colors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('AI Asistan hazır!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            'Matematik, fen bilimleri, programlama\nve daha fazlası için sor.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: onStart,
            child: const Text('Sohbete Başla'),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Msg msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: SelectableText(
            msg.text,
            style: TextStyle(color: colors.onPrimary, height: 1.4),
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
            child: Icon(Icons.auto_awesome_rounded,
                size: 18, color: colors.onPrimaryContainer),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              margin: const EdgeInsets.only(bottom: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2)),
              ),
              child: SelectableText(
                msg.text,
                style: TextStyle(color: colors.onSurface, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 42),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 150),
            const SizedBox(width: 4),
            _Dot(delay: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isTyping,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outline.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              enabled: !isTyping,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Bir şeyler sor...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isTyping ? null : onSend,
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
